CREATE PROCEDURE "informix".sp_buscar_movimientos_his_credito_mc(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto MONEY(14,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones LVARCHAR, p_sNumeroEmpresa CHAR(3))
    RETURNING DATE AS fechamovimientohistorico, DATETIME HOUR TO FRACTION(3) AS horamovimientohistorico, MONEY(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(30) AS referencia23, CHAR(1) AS reversado, CHAR(40) AS refComercio,  DATE AS fechacConsumo, DATETIME HOUR TO FRACTION(3) AS horaConsumo;
	
	-- Definicion de variables	    
	DEFINE resultado_fechamovimientohistorico    DATE;
	DEFINE resultado_monto				MONEY(16,2);
	DEFINE saldo_favor    				MONEY(16,2);
	DEFINE resultado_horamovimientohistorico		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
   	DEFINE resultado_claveTipo          CHAR(5);
   	DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_referencia23		CHAR(30);
    DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	DEFINE res_fechamovimientohistorico_ret    	DATE;
	DEFINE res_horamovimientohistorico_ret		DATETIME HOUR TO FRACTION(3);
	DEFINE res_fechamovimientohistorico_re1	 	DATE;
	DEFINE res_horamovimientohistorico_re1	 	DATETIME HOUR TO FRACTION(3);
	DEFINE bin_tdc_coppel_mc 			CHAR(6);
	DEFINE resultado_infreceptor 		CHAR(23);
	DEFINE parametro1                   CHAR(30);
    DEFINE parametro2                   CHAR(30);
    DEFINE parametro3                   CHAR(30);
    DEFINE p_secuenciaextendida         CHAR(30);	
	
    -- Inicializacion de variables
	LET resultado_fechamovimientohistorico = '';
	LET resultado_monto = '';
	LET saldo_favor = '';
	LET resultado_horamovimientohistorico = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
    LET resultado_sucursal = '';
    LET resultado_nombre = '';
    LET resultado_claveTipo = '';
	LET resultado_tipo = '';
    LET resultado_referencia23 = '';
    LET resultado_reversado = '';
	LET resultado_refComercio = '';
    LET transacciones = 'LIST{' || ids_transacciones || '}';
	LET res_fechamovimientohistorico_ret = '';
	LET res_horamovimientohistorico_ret  = TO_DATE("00:00","%H:%M");
	LET res_fechamovimientohistorico_re1 = '';
	LET res_horamovimientohistorico_re1  = TO_DATE("00:00","%H:%M");
	LET bin_tdc_coppel_mc       = '514014';
	LET resultado_infreceptor   = '';
	LET parametro1              = '';
	LET parametro2              = '';
	LET parametro3              = '';
	LET p_secuenciaextendida    = '';
	
	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/sp_buscar_movimientohistoricos_credito_mc.out";
	--TRACE ON;
	
	BEGIN
		
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET resultado_fechamovimientohistorico = '';
				LET resultado_monto = '';
				LET saldo_favor = '';
				LET resultado_horamovimientohistorico = TO_DATE("00:00","%H:%M");
				LET resultado_folioSuc = '';
				LET resultado_sucursal = '';
				LET resultado_nombre = '';
				LET resultado_claveTipo = '';
				LET resultado_tipo = '';
				LET resultado_referencia23 = LPAD (resultado_referencia23,23,"0");
				LET resultado_reversado = '';
				LET resultado_refComercio = '';
				LET res_fechamovimientohistorico_ret = '';
				LET res_horamovimientohistorico_ret  = TO_DATE("00:00","%H:%M");
				RETURN resultado_fechamovimientohistorico, resultado_horamovimientohistorico, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechamovimientohistorico_ret, res_horamovimientohistorico_ret;
			END IF;
		END EXCEPTION;
				
			FOREACH       				
				
				SELECT DISTINCT	fechahoraacentral, DATE(fechahoraacentral), monto, 'i'||fechalocaltransaccion||SUBSTRING(horalocaltransaccion FROM 1 FOR 4)||secuencia AS folio_suc,	movreversado, SUBSTRING(infreceptor FROM 1 FOR 22) AS infreceptor, secuenciaextendida
				INTO resultado_horamovimientohistorico, resultado_fechamovimientohistorico, resultado_monto, resultado_folioSuc, resultado_reversado, resultado_infreceptor, p_secuenciaextendida
				FROM intercard:movimientohistorico
					LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:movimientohistorico.numtarjeta)
				WHERE intercard:tarjetacuenta.numcuenta = p_sNumeroCuenta
				    AND date(fechahoraacentral) <= p_sFechaFinal
					AND date(fechahoraacentral) >= p_sFechaInicial
					AND intercard:movimientohistorico.numtarjeta = p_sTarjeta
					AND intercard:movimientohistorico.formato = '0200'
					AND UPPER(movreversado) = 'F'
					AND intercard:movimientohistorico.codigoiso = '00'
                    AND intercard:movimientohistorico.metodocaptura IN ('01', '05')
					ORDER BY folio_suc ASC, fechahoraacentral ASC
					
					LET resultado_claveTipo = '6830';
				    LET resultado_tipo = 'COMPRA EN COMERCIO';
				   -- LET resultado_fechamovimientohistorico = resultado_horamovimientohistorico;
				
				-- Obtener referencia23
				SELECT DISTINCT referencia23_325 INTO resultado_referencia23
				FROM intercard:movimientohistorico mov
				LEFT JOIN bditarjeta:td_movimientohistoricos_conciliacion ON (bditarjeta:td_movimientohistoricos_conciliacion.secuencia_extendida = mov.secuenciaextendida and bditarjeta:td_movimientohistoricos_conciliacion.numtarjeta = mov.numtarjeta)
				WHERE mov.numtarjeta = p_sTarjeta
				AND bditarjeta:td_movimientohistoricos_conciliacion.archivo_origen in (SELECT valor FROM  bdinteg:si_param_tdc_coppelmc WHERE codigo_parametro = 3) --codigo_parametro 3 = VNC
				AND mov.codigoiso = '00' and mov.movreversado = 'F' and mov.movconciliado = 'V'
				AND mov.secuenciaextendida = p_secuenciaextendida;
				
                -- Obtener sucursal y nombre sucursal			
				SELECT valor into resultado_sucursal FROM  bdinteg:si_param_tdc_coppelmc WHERE codigo_parametro = 1;
				SELECT valor into resultado_nombre FROM  bdinteg:si_param_tdc_coppelmc WHERE codigo_parametro = 2;
				
				LET resultado_refComercio = TRIM(resultado_folioSuc)||' '||resultado_infreceptor;
				LET res_fechamovimientohistorico_ret = resultado_fechamovimientohistorico;
				LET res_horamovimientohistorico_ret = resultado_horamovimientohistorico;
				
				RETURN resultado_fechamovimientohistorico, resultado_horamovimientohistorico, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, 
				resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechamovimientohistorico_ret, res_horamovimientohistorico_ret WITH RESUME;
			END FOREACH;
		
	END;
END PROCEDURE
DOCUMENT
'Sp para busqueda de movimientohistoricos de Credito Coppel Masterd Card',
'SISTEMA: Aclaraciones',
'AREA: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'COORDINADOR: Jorge Alberto Lara Mendoza',
'FECHA: 01/Septiembre/2022',
'VERSION: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_buscarclientesporcuenta (p_sNumeroCuenta CHAR(30), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE estatus_cta					CHAR(1);
	DEFINE iSqlErr                      	INTEGER;

     -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET estatus_cta = '';
	LET resultado_segundoNombre = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
            END EXCEPTION;

		/*	
		SELECT  status_cta
		INTO estatus_cta
		FROM bdicheq:sc_maechq
		WHERE cuenta = p_sNumeroCuenta;
		
		IF (estatus_cta='2') THEN 
			LET p_sNumeroCuenta = '';
		END IF;
		*/	
			
        FOREACH
            SELECT num_cte
            INTO resultado_numeroCliente
            FROM bdicheq:sc_maechq
            WHERE cuenta = p_sNumeroCuenta
            UNION
            SELECT num_cte
            FROM bdinvers:sv_maeinv
            WHERE empresa = p_sNumeroEmpresa
              AND cuenta = p_sNumeroCuenta
            UNION
            SELECT numcte
            FROM bdicred:sd_maecred
            WHERE empresa = p_sNumeroEmpresa
              AND num_credito = p_sNumeroCuenta
            UNION
            SELECT numcliente 		--JALM
            FROM intercard:tarjeta
			LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numcuenta = p_sNumeroCuenta
			UNION
            SELECT numcte
            FROM bditransfer:tf_maecte
            WHERE empresa = p_sNumeroEmpresa
              AND cuenta_tf = p_sNumeroCuenta
        END FOREACH;

        if ( resultado_numeroCliente IS null ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT si_cliente.numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente;

            if ( resultado_numeroCliente IS null ) THEN
               let resultado_numeroCliente = '';
            END if;
        END if;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT 'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de clientes correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_buscarclientesportarjeta (p_sNumeroTarjeta CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--	    
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE cuenta_tarjeta				CHAR(30);
	DEFINE iSqlErr                     	INTEGER;
	
    -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET cuenta_tarjeta = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;
         
   
		SELECT numcuenta
		INTO cuenta_tarjeta
		FROM intercard:tarjetacuenta
		WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta;
            
        IF (cuenta_tarjeta IS NULL)THEN
        
        SELECT cuenta_tf
		INTO cuenta_tarjeta
		FROM bditransfer:tf_maecte
		WHERE empresa = '001'
		AND bditransfer:tf_maecte.num_tarjeta = p_sNumeroTarjeta;
         
        END IF;

        FOREACH
            SELECT num_cte
            INTO resultado_numeroCliente
            FROM bdicheq:sc_maechq
            WHERE empresa = '001'
              AND cuenta = cuenta_tarjeta
            UNION
             SELECT numcte
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
            AND cuenta_tf = cuenta_tarjeta
            UNION
            SELECT num_cte
            FROM bdinvers:sv_maeinv
            WHERE empresa = '001'
              AND cuenta = cuenta_tarjeta
            UNION
            SELECT numcliente 		--JALM
            FROM intercard:tarjeta
			LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numcuenta = cuenta_tarjeta
			UNION
            SELECT numcte
            FROM bdicred:sd_maecred
            WHERE empresa = '001'
              AND num_credito = cuenta_tarjeta
			  AND status_cred IN ('AA','BA','BT','E1','E2','E3') -- Agregado
			--IFRS Se contemplan los nuevos estatus por Etapas			
			--AND status_cred IN ('AA','BA','BT')			  
           
        END FOREACH;
		
           
     IF ( resultado_numeroCliente IS NULL ) THEN
            let resultado_numeroCliente = '';
        ELSE
            SELECT si_cliente.numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente;
{
            IF ( resultado_numeroCliente IS NULL ) THEN
               
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				
            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT 'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de clientes correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Noviembre/2022',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_regresaticket()

--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(50)	AS ticket;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_regresaticket "
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 27/01/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021

folio:Cambio
Autor.........: Juan Francisco Ponce Damian
Fecha.........: 26/10/2021
Modificacion..: Se limita a 1000 la cantidad maxima de tickets por ejecuciÃ³n y se ordenan de mas antiguas a mas nuevos.
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iContador		INTEGER;
DEFINE cTicket			CHAR(50);
DEFINE cMinutos			INTEGER;
DEFINE dFecha			DATETIME YEAR TO SECOND;

-- SET DEBUG FILE TO '/home/sysifx/sp_regresaticket.out';
-- TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00001';
LET iSqlErr				= 0;
LET iContador			= 0;
LET cTicket				= '';
LET cMinutos			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTicket;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT TO_NUMBER(valor) INTO cMinutos FROM "informix".si_param WHERE cod_param = '502' AND empresa = '001';
	LET dFecha = (CURRENT - cMinutos UNITS MINUTE);
	
	FOREACH
	    SELECT limit 1000 ticket INTO cTicket 
		FROM "informix".si_rostro_linea 
		WHERE status_consulta = '2'
		AND ticket != ''
		AND fecha_env <= dFecha ORDER BY fecha_env ASC

		LET cCodRet = '00000';
		
		LET iContador = iContador + 1;
		
		RETURN cCodRet, cTicket WITH RESUME;
		
	END FOREACH;
		
	IF (iContador <= 0) THEN
		RETURN cCodRet, cTicket WITH RESUME;
	END IF;
END;
END PROCEDURE;