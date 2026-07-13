CREATE PROCEDURE "informix".trans_prestamo2( pc_costos CHAR(4),
                                            pusuario CHAR(8),
                                            pfolio CHAR(16),
                                            pcuenta CHAR(20),
                                            pnum_tarjeta CHAR(16),
                                            pfecha DATE,
                                            pmto_tot DECIMAL(14,2),
                                            pmoneda CHAR(3),
                                            preferencia CHAR(40),
											pctecoppel CHAR (10))
RETURNING CHAR(5), CHAR(11);

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);

    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vprecio_udi      DECIMAL(14,6);
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6);
    DEFINE vmtopagosudi     DECIMAL(18,6);
    DEFINE vlim_cuenta      DECIMAL(18,6);
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vmtoglobcap      DECIMAL(20,6);
    DEFINE vmtomensacum     DECIMAL(20,6);
    DEFINE vexiste          CHAR(20);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vtranprestcoppel  CHAR(4);
    DEFINE vnomaxudis       SMALLINT;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE wcuenta          CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE vproceso         CHAR(1);
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vexiste_hoy      SMALLINT;
    DEFINE vexiste_mes      SMALLINT;
    DEFINE vtrx_dia         SMALLINT;
    DEFINE vtrx_mes         SMALLINT;
    DEFINE vnumcte          CHAR(20);
	DEFINE vlim_dep          INTEGER;
	DEFINE vNoCteBanco		CHAR(9);
	DEFINE vUltDigTrj  		CHAR(16);

    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vproceso = '0';

    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vprecio_udi      = 0.00;
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vporcapcorres    = 0.00;
    LET vmtoglobcap      = 0.00;
    LET vmtomensacum     = 0.00;
    LET vexiste          = '';
    LET vtransaccion     = 0;
    LET vnomaxudis       = 0;
    LET vhoramax         = '';
    LET vtranprestcoppel = '';
    LET wcuenta          = '';
    LET vstatus_tar      = '';
    LET vind_cierre      = '0';
    LET vind_dispon      = '0';
    LET vexiste_hoy      = 0;
    LET vexiste_mes      = 0;
    LET vtrx_dia         = 0;
    LET vtrx_mes         = 0;
    LET vnumcte          = '';
	LET vlim_dep 		 = 0;
	LET vNoCteBanco 	= '';
	LET vUltDigTrj  	= '';

     --SET DEBUG FILE TO "trans_prestamo.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
         -- SET DEBUG FILE TO "/resplogifx/conciliachq/trans_prestamo.err";
         -- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            END IF;
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    -- // Obtiene fechas del sistema de cheques
    SELECT fecha_hoy, ind_cierre, ind_disponible
      INTO vfecha_hoy, vind_cierre, vind_dispon
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret1 = '004';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    -- // VALIDACION DE PARAMETROS
    LET pmto_tot = pmto_tot / 100;
	LET pmoneda = '001';
	
	--VALIDA TARJETA 4 DIGITOS Y NUMCTE CON DATOS
	IF SUBSTR(pnum_tarjeta, 1,12) = "000000000000" AND pctecoppel != "" THEN 
		LET pnum_tarjeta = SUBSTR(pnum_tarjeta,13,4);
		
		SELECT numcte_banco
			INTO vNoCteBanco
		FROM bdinteg:si_relacion_ctebcplcpl
		WHERE cliente = pctecoppel; 
		
		--Mejora para ctes no relacionados 19072024
		IF vNoCteBanco is null OR vNoCteBanco = '' THEN
			SELECT numcte 
			INTO vNoCteBanco
			FROM bdinteg:si_cliente
			WHERE numcte_ref = pctecoppel; 
		END IF;
		--Mejora para ctes no relacionados 19072024
		
		IF vNoCteBanco is null OR vNoCteBanco = '' THEN 
			LET vCodRet1 = '00111';
			RETURN vcodret1, TRIM(pcuenta);
		ELSE
		 FOREACH 		
			SELECT trj.num_tarjeta
				INTO vUltDigTrj
			FROM bdicheq:sc_tarjeta trj,
               bdicheq:sc_maechq mae
			WHERE trj.cuenta = mae.cuenta
			AND trj.numcte = mae.num_cte
			AND trj.tipo_tarjeta = 'T'
			AND trj.status_tar = 'A'
			AND mae.status_cta IN('1','3','4','5')
			AND mae.num_cte = vNoCteBanco
			
			
			IF SUBSTR(vUltDigTrj, 13, 4) = pnum_tarjeta THEN 
			LET pnum_tarjeta = vUltDigTrj;
		    EXIT FOREACH;
			END IF;
		  END FOREACH;
		 END IF;
	END IF;

    IF ( pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4 ) OR
       ( pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) OR
       ( ( pcuenta is null OR pcuenta = '' OR LENGTH(pcuenta) <> 11 ) AND ( pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16 ) ) OR
       ( pfecha is null OR pfecha = '' ) OR
       ( pmto_tot is null OR pmto_tot <= 0.00 ) OR
       ( pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03 ) THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
	
	
	--VALIDA LIMITE MAXIMO MONTO pmto_tot
	SELECT valor::int
	INTO vlim_dep
	FROM bdicheq:sc_param
	WHERE empresa  = '001'
	AND codparam = 'LimTransPresCoppel'; 
	
	IF pmto_tot >= vlim_dep THEN
        LET vcodret1 = '303';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3];
    END IF;
	

    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar, numcte
          INTO pcuenta, vstatus_tar, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjeta;

        IF vstatus_tar <> 'A' THEN
            LET vcodret1 = '200';
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END IF;

    IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
        SELECT num_tarjeta, numcte
          INTO pnum_tarjeta, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pcuenta
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pcuenta)
           AND status_tar = 'A';

        IF pnum_tarjeta is null THEN
            LET pnum_tarjeta = '';
        END IF;
    END IF;

    -- // VALIDA EL NUMERO DE CLIENTE
    IF vnumcte is null OR vnumcte = '' THEN
        SELECT num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pcuenta;
    END IF;

    -- // VALIDA TRANSACCIONES PERMITIDAS POR DIA
    SELECT valor::int
      INTO vtrx_dia
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'NoTrxsDiaTranPres';

    SELECT COUNT(*)
      INTO vexiste_hoy
      FROM bdicheq:sc_acumtrapres
     WHERE numcte = vnumcte
       AND fecha = vfecha_hoy;

    IF vexiste_hoy >= vtrx_dia THEN
        LET vcodret1 = '302';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    -- // VALIDA TRANSACCIONESPOR PERMITIDAS POR MES
    SELECT valor::int
      INTO vtrx_mes
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'NoTrxsMesTranPres';

    SELECT COUNT(*)
      INTO vexiste_mes
      FROM bdicheq:sc_acumtrapres
     WHERE numcte = vnumcte;

    IF vexiste_mes >= vtrx_mes THEN
        LET vcodret1 = '302';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    -- // OBTIENE NUMERO DE TRANSACCION
    SELECT TRIM(valor)
      INTO vtranprestcoppel
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = "tranprestcoppel";

    IF vtranprestcoppel is null OR vtranprestcoppel = '' THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    LET pc_costos='5006';

    -- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE CHEQUES
    EXECUTE PROCEDURE bdicheq:abono_ref( "001",             --- empresa
                                         pc_costos,         --- sucursal
                                         pusuario,          --- usuario
                                         vtranprestcoppel,  --- transaccion
                                         "0000",            --- transaccion suc
                                         pfolio,            --- folio suc
                                         pcuenta,           --- cuenta
                                         0,                 --- cheque
                                         pmto_tot,          --- monto total
                                         pmto_tot,          --- monto firme
                                         0,                 --- monto SBC
                                         0,                 --- monto REM
                                         0,                 --- dias ret
                                         pmoneda,           --- divisa
                                         preferencia,       --- referencia
                                         pnum_tarjeta,      --- no. tarjeta
                                         " " )              --- usuario autoriza
    INTO vcodret1;

    IF vcodret1 = '000' THEN
        LET vproceso = '1';

        INSERT INTO bdicheq:sc_acumtrapres VALUES
        ( pcuenta, pfolio, pmto_tot, vfecha_hoy, vnumcte );
    ELSE
        IF vcodret1 = '110' OR
           vcodret1 = '106' OR
           vcodret1 = '420' OR
           vcodret1 = '552' OR
           vcodret1 = '959' OR
           vcodret1 = '956' OR
           vcodret1 = '401' OR
           vcodret1 = '549' THEN
            LET vcodret1 = '110';
        END IF;

        IF vcodret1 = '100' THEN
            LET vcodret1 = '100';
        END IF;

        IF vcodret1 = '200' THEN
            LET vcodret1 = '200';
        END IF;

        IF vcodret1 = '951' THEN
            LET vcodret1 = '951';
        END IF;

        IF vcodret1 = '301' THEN
            LET vcodret1 = '302';
        END IF;

        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    RETURN vcodret1, TRIM(pcuenta);

    END;

END PROCEDURE
DOCUMENT
'realiza las transferencias de prestamos para el servicio wstransferenciascloud',
'AUTOR : Luis Fernando Trapero Soto',
'FECHA :MAYO/2024',
'BD    : bdicheq',
'-----------------------------------------------',
'Se valida el limite del monto de transferencias en la tabla sc_param',
'AUTOR : Luis Fernando Trapero Soto',
'BD    : bdicheq',
'FECHA :11/JUN/2024',
'-----------------------------------------------',
'Se realiza clon del sp trans_prestamo, para realizar deposito con los ',
'ultimos 4 digitos de la tarjeta sin afectar el proceso con los 16 digitos',
'AUTOR : Luis Fernando Trapero Soto',
'BD    : bdicheq',
'FECHA :11/JUN/2024',
'-----------------------------------------------',
'se agrega la consulta si_cliente para busqueda ',
'de clientes que aun no exiten en la relacion coppel bancoppel',
'AUTOR : Luis Alberto Beltran Rodriguez',
'BD    : bdicheq',
'FECHA :17/JUL/2024';

CREATE PROCEDURE "informix".sp_validaasignaciontdd
(
pNumCte CHAR(20),
pNumTarjeta CHAR(20),
pIdentificador SMALLINT
)
	--DATOS A REGRESAR--
	RETURNING CHAR(5) As CodigoRetorno;  -- Codigo de Retorno
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet				CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE iExisteBdicheq		SMALLINT;
	DEFINE iExisteIntercard		SMALLINT;
	

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet					= '00000';
	LET iSqlErr					= 0;
	LET iExisteBdicheq			= 0;
	LET iExisteIntercard		= 0;
		
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
	BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet;  
        END IF;
    END EXCEPTION;


	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

-- ****************************************************************************
-- *                    	VALIDAR PARAMETROs  	 		                  *
-- ****************************************************************************

	IF NVL(TRIM(pNumcte),'') = '' OR NVL(TRIM(pNumTarjeta),'') = '' OR pIdentificador IS NULL THEN
		LET cCodRet = '00001'; --ALGUNO DE LOS PARAMETROS ESTA VACIO O NULO
		RETURN cCodRet;
	END IF;
			
-- ****************************************************************************
-- *                        PROCESO PRINCIPAL                                *
-- ****************************************************************************
	
	LET pNumTarjeta = trim(pNumTarjeta);
	LET pNumCte = trim(pNumCte);
	
	IF pIdentificador = 1 THEN  ---	Valida que tarjeta NO tenga datos registrados
		
		SELECT COUNT(*)
		INTO iExisteIntercard
		FROM intercard:"informix".tarjeta
		WHERE numtarjeta = pNumTarjeta
		AND numtarjeta IN (SELECT numtarjeta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta = pNumTarjeta);
		
		IF iExisteIntercard > 0 THEN
			LET cCodRet = '01237'; -- Tarjeta Tiene datos en tablas de intercard
			RETURN cCodRet;
		ELSE
			SELECT COUNT(*)
			INTO iExisteBdicheq
			FROM "informix".sc_tarjeta
		    WHERE empresa = '001'
			AND num_tarjeta = pNumTarjeta
			AND numcte = pNumCte;
			
			IF iExisteBdicheq > 0 THEN
				DELETE FROM "informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pNumTarjeta AND numcte = pNumCte;
			END IF;
			
		END IF;
			
	ELIF pIdentificador = 2 THEN  ---	Limpiar la tarjeta en caso de que se presente algun error en la asignaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de la misma.
			
			--Se valida si el la tarjeta tiene registro en las tablas de intercar para no eliminar el registro de la tabla sc_tarjeta
			-- Y activar el plastico, para evitar tarjetas incompletas
			SELECT COUNT(*) INTO iExisteIntercard FROM intercard:"informix".tarjeta a
			INNER JOIN bdicheq:"informix".sc_tarjeta b ON a.numtarjeta = b.num_tarjeta AND a.numcliente = b.numcte
			INNER JOIN intercard:"informix".tarjetacuenta c ON c.numcuenta = b.cuenta
			WHERE a.numtarjeta = pNumTarjeta AND a.numcliente = pNumCte AND a.codstatustarjeta = 'INA';
			
			IF iExisteIntercard > 0 THEN
			
				UPDATE intercard:"informix".tarjeta SET codstatustarjeta ='ACT' 
				WHERE numtarjeta =  pNumTarjeta AND numcliente = pNumCte AND codstatustarjeta = 'INA';
			
			ELSE			
								
				DELETE FROM "informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pNumTarjeta AND numcte = pNumCte;
				
			END IF;
			
	
   ELIF pIdentificador = 3 THEN  ---	Borra la tarjeta de la sc_tarjeta caso de que  falle la asignacion
			
				DELETE FROM "informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pNumTarjeta AND numcte = pNumCte;
								
	END IF
	
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR: 		JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 		15/07/2015',
'DESCRIPCION: 	Se crea procedimiento para validar la integridad de las tarjetas,',
' 				pIdentificador = 1 (Valida que tarjeta NO tenga datos registrados),',
' 				pIdentificador = 2 (Limpiar la tarjeta en caso de que se presente algun error en la asignaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de la misma).',
'               pIdentificador = 3 (Se usa en el catch de la asignacion)',
'SUSTENTO: 		 ',
'SOLICITO: 		Cutberto GonzÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡lez PÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©rez',
'BD: 			bdicheq',
'SISTEMA: 		astardeb.exe';

CREATE PROCEDURE "informix".sp_saldos_altos ( pempresa char(3))
RETURNING   CHAR(5);


DEFINE vsqlerr        INTEGER;
DEFINE vcodret        CHAR(5);

DEFINE v_num_cte      CHAR(20);
DEFINE v_suc_cuenta   CHAR(4); 
DEFINE v_dep_efec     MONEY(14,2);
DEFINE v_retiros      MONEY(14,2);
DEFINE v_rem_cargo    MONEY(14,2);
DEFINE v_rem_abono    MONEY(14,2);
DEFINE v_spei_rec     MONEY(14,2);
DEFINE v_spei_env     MONEY(14,2);
DEFINE v_fecha_hoy    DATE; 
DEFINE v_p_dia_ante   DATE;
DEFINE v_u_dia_ante   DATE;
DEFINE v_pri_dia_mes  DATE;
DEFINE vsql           CHAR(500);
DEFINE v_f_fin        VARCHAR(8);
DEFINE v_anio_fin     INTEGER;
DEFINE v_mes_fin      CHAR(2);
DEFINE v_dia_fin      CHAR(2);
DEFINE vsflagentransaccion     CHAR(1);
DEFINE vicontadorregistros     INTEGER;
DEFINE vmmonto_tot    MONEY(14,2);
DEFINE vctransacc     CHAR(4);
DEFINE vcnum_cte      CHAR(20);
DEFINE vcsucursal     CHAR(4);
DEFINE vCuenta,vEstatus INTEGER; 
DEFINE vMaxFecha      INTEGER;

LET vsqlerr = 0; 
LET vcodret = "00000";
LET vCuenta = 0;
LET vEstatus = 0;
LET vMaxFecha = 0;

BEGIN
	   ON EXCEPTION SET vsqlerr
	      SET DEBUG FILE TO "/resplogifx/conciliachq/error_saldos.err";
	   	   TRACE ON;
              IF vsqlerr <> 0 THEN
                 LET vcodret = vsqlerr;
                 RETURN vcodret;
              END IF;
       END EXCEPTION;
	   
       --SET DEBUG FILE TO '/resplogifx/conciliachq/saldos.txt';
	   --TRACE ON;
	   
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	   --TABLA QUE CONCENTRA TODOS LOS MOVIMIENTOS 
	   --CREATE TABLE sc_mov_cliente
	   --      (fecha DATE NOT NULL, 
	   --         monto        MONEY(14,2),
	   --		  num_cte      CHAR(20),
	   --		  transaccion  CHAR(4),
	   --		  sucursal     CHAR(4)) IN dbssc_maechq; 
					
	   --TABLA QUE CONCENTRA LOS NUMEROS DE CLIENTES
	   --CREATE TABLE sc_mov_cliente_sup_lim
       --     (num_cte      CHAR(20)) IN dbssc_maechq;
			 
	   
       --************************************************************
       -- Mantenimiento por Softtek case3
       -- fecha : 21/05/2024
       -- Funcion: Se aplica el uso de commit cada 500 registros 
       --************************************************************

									 

	   --SE OBTIENEN LAS  FECHAS PARA EL PROCESO 
	   SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY),fecha_hoy	, pri_dia_mes
         INTO v_p_dia_ante,v_u_dia_ante,v_fecha_hoy,v_pri_dia_mes
         FROM  sc_fechas; 
	
           BEGIN;
           TRUNCATE TABLE sc_saldos_altos;
           COMMIT;
           BEGIN;
           TRUNCATE TABLE sc_mov_cliente_sup_lim;
           COMMIT;

	
		LET vCuenta = 0;
		--VALIDA QUE NO SE HAYA EJECUTADO EL SP EN EL PERIODO
		SELECT COUNT(*),estatus INTO vCuenta,vEstatus FROM sc_control_procesos WHERE proceso='sp_saldos_altos' AND fecha = v_pri_dia_mes GROUP BY 2;
		
		IF vCuenta = 0 OR vCuenta IS NULL THEN
           --LIMPIA TABLA DETECTA QUE SE EJECUTA EL SP POR PRIMERA VEZ 
		   BEGIN;
		   		INSERT INTO sc_control_procesos VALUES('sp_saldos_altos',v_pri_dia_mes,0);
		   COMMIT;	 
		   BEGIN;
		   TRUNCATE TABLE sc_mov_cliente;
		   COMMIT;
		END IF; 
		IF vCuenta = 1 AND vEstatus=1 THEN
		   --LIMPIA TABLA DETECTA QUE YA SE HABIA EJECUTADO EL SP EN EL PERIODO Y LO REPROCESA DESDE CERO
           BEGIN;
           TRUNCATE TABLE sc_mov_cliente;
           COMMIT;
           BEGIN;
                UPDATE sc_control_procesos SET estatus=0 WHERE proceso='sp_saldos_altos' AND fecha= v_pri_dia_mes;
           COMMIT;
        ELSE 
			IF vCuenta = 1 AND vEstatus=0 THEN
		        --LIMPIA TABLA DETECTA QUE EL SP NO CONCLUYO EN SU ANTERIOR EJECUCION E INICIA EN EL PUNTO EN EL CUAL SE QUEDO 
				SELECT MAX(fecha)
				INTO vMaxFecha
				FROM bdicheq:sc_mov_cliente WHERE fecha >= v_p_dia_ante and fecha <= v_u_dia_ante;
			    LET v_p_dia_ante = vMaxFecha; 
                DELETE FROM bdicheq:sc_mov_cliente where fecha >= v_p_dia_ante AND fecha <=v_u_dia_ante; 	
			END IF; 
		END IF; 
        ---REMESAS CARGO - REMESAS ABONO
	    ---SPEI RECIBIDO - SPEI ENVIADO
	    ---REMESAS CARGO - REMESAS ABONO
		WHILE v_p_dia_ante <= v_u_dia_ante 
			LET vsflagentransaccion = 'F';		   
			LET vicontadorregistros = 0;
	        
			foreach cur_sc_movhis_01 with hold
            for
				SELECT
						 mh.monto_tot,
						 mc.num_cte,
						 mh.transacc,
						 mc.sucursal
					INTO vmmonto_tot,vcnum_cte,vctransacc,vcsucursal
					FROM sc_movhis AS mh,
						 sc_maechq AS mc
				   WHERE mc.cuenta = mh.cuenta
					 --AND (mh.fech_alt >= v_p_dia_ante AND mh.fech_alt <= v_u_dia_ante)     
					 AND mh.fech_alt = v_p_dia_ante		
					 AND mh.cancelad <> 'S'
					 AND mh.transacc IN('0202','0325','0282','0223',
										'0273','0274',
										'1110','1140','1325',
										'1355','1121','1151',
										'1122','1152','1123',
										'1170','1385','1181','1182')
					 AND mc.producto = '1300'
					 AND mc.status_cta NOT IN('2', '6', '7', '8')

					if(vsflagentransaccion = 'F') then
						begin work;
						let vsflagentransaccion = 'V';
					end if;
					INSERT INTO sc_mov_cliente(fecha,monto,num_cte,transaccion,sucursal) VALUES(v_p_dia_ante,vmmonto_tot,vcnum_cte,vctransacc,vcsucursal);
					let vicontadorregistros = vicontadorregistros + 1;
					
					if (vicontadorregistros = 500) then
						commit work;
						let vsflagentransaccion = 'F';
						let vicontadorregistros = 0;
						continue foreach;
					end if;
			end foreach;     
			if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
			end if;
	 
			LET vsflagentransaccion = 'F';	   
			LET vicontadorregistros = 0;	 
			foreach cur_sc_movhis_02 with hold
				for
				 SELECT
                 		 mh.monto_tot,
						 mc.num_cte,
						 mh.transacc,
						 mc.sucursal
				    INTO vmmonto_tot,vcnum_cte,vctransacc,vcsucursal
					FROM sc_movhis_old AS mh,
						 sc_maechq AS mc
				   WHERE mc.cuenta = mh.cuenta 
					 --AND (mh.fech_alt >= v_p_dia_ante AND mh.fech_alt <= v_u_dia_ante)  
                     AND mh.fech_alt = v_p_dia_ante					 
					 AND mh.cancelad <> 'S'
					 AND mh.transacc IN('0202','0325','0282','0223',
										'0273','0274',
										'1110','1140','1325',
										'1355','1121','1151',
										'1122','1152','1123',
										'1170','1385','1181','1182')
					 AND mc.producto = '1300'
					 AND mc.status_cta NOT IN('2', '6', '7', '8')

					if(vsflagentransaccion = 'F') then
						begin work;
						let vsflagentransaccion = 'V';
					end if;
					INSERT INTO sc_mov_cliente(fecha,monto,num_cte,transaccion,sucursal) VALUES(v_p_dia_ante,vmmonto_tot,vcnum_cte,vctransacc,vcsucursal);

					let vicontadorregistros = vicontadorregistros + 1;
					
					if (vicontadorregistros = 500) then
						commit work;
						let vsflagentransaccion = 'F';
						let vicontadorregistros = 0;
						continue foreach;
					end if;
			end foreach;     
			if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
			end if;	 	  
		LET v_p_dia_ante = v_p_dia_ante + 1 UNITS DAY;
		END WHILE;
        --CREATE INDEX idx_sc_mov_cliente_tran
        --ON sc_mov_cliente ( transaccion ) IN dbs_movhis_idx4 ONLINE;


        --CREATE INDEX idx_sc_mov_cliente_tran_clie
        --ON sc_mov_cliente ( transaccion,num_cte ) IN dbs_movhis_idx4 ONLINE;


        --CREATE INDEX idx_sc_mov_cliente_sucursal
        --ON sc_mov_cliente ( sucursal ) IN dbs_movhis_idx4 ONLINE;


        UPDATE STATISTICS MEDIUM FOR TABLE sc_mov_cliente(transaccion,num_cte);

		 ----SE EXTRAEN LOS USUARIOS QUE SUPERAN LOS LIMITES
		 ----DEPOSITOS EN EFECTIVO 
		  BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion IN('0202','0325','0282')
		  GROUP BY num_cte
         HAVING SUM(monto)> 20000;
		 COMMIT;
		 
		 
		 ----DEPOSITOS RETIROS
		 BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion = '0223'
		  GROUP BY num_cte
         HAVING SUM(monto)> 20000;
		 COMMIT;
		 
		 
		  ---SPEI RECIBIDO  
		  BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion ='0273'
		  GROUP BY num_cte
         HAVING SUM(monto)> 30000;
		 COMMIT;
		 
		 
		 --- SPEI ENVIADO 
		  BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion = '0274'
		  GROUP BY num_cte
         HAVING SUM(monto)> 30000;
		 COMMIT;

				 
		  ---REMESAS CARGO 
		  BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion IN('1110','1140','1325',
							   '1355','1121','1151',
							   '1122','1152','1123')
		  GROUP BY num_cte
         HAVING SUM(monto)> 5000;
		 COMMIT;
		 
		 
		 
		  --- REMESAS ABONO 
		  BEGIN;
		 INSERT INTO sc_mov_cliente_sup_lim(num_cte)
		 SELECT num_cte	
		   FROM sc_mov_cliente
		  WHERE transaccion IN('1170','1385','1181','1182')
		  GROUP BY num_cte
         HAVING SUM(monto)> 5000;
		 COMMIT;

       --CREATE INDEX idx_sc_mov_cliente_sup_lim
       --ON sc_mov_cliente_sup_lim (num_cte) IN dbs_movhis_idx4 ONLINE;
	   
       UPDATE STATISTICS MEDIUM FOR TABLE sc_mov_cliente_sup_lim(num_cte);	 		 		 

       LET vsflagentransaccion = 'F';	   
	   LET vicontadorregistros = 0;	  

       FOREACH WITH HOLD		
		           SELECT DISTINCT(num_cte)
		             INTO v_num_cte
		             FROM sc_mov_cliente_sup_lim
		
		
				   ---SE OBTIENE LOS DEPOSITOS 			   
                   SELECT SUM(monto) 
				     INTO v_dep_efec
				     FROM sc_mov_cliente
                    WHERE transaccion IN('0202','0325','0282')
                      AND num_cte = v_num_cte;
					  
					  
					   IF v_dep_efec IS NULL OR v_dep_efec = '' THEN 
				          LET v_dep_efec = 0; 
				      END IF;
				   
				   
				   ---SE OBTIENE LOS RETIROS 	
				   SELECT SUM(monto) 
				     INTO v_retiros
				     FROM sc_mov_cliente
                    WHERE transaccion = '0223'
                      AND num_cte = v_num_cte;
					  
					  IF v_retiros IS NULL OR v_retiros = '' THEN 
				         LET v_retiros = 0; 
				     END IF;
					 
					 
					 ---SE OBTIENE LOS SPEI RECIBIDO 	
				   SELECT SUM(monto) 
				     INTO v_spei_rec
				     FROM sc_mov_cliente
                    WHERE transaccion = '0273'
                      AND num_cte = v_num_cte;
					  
					   IF v_spei_rec IS NULL OR v_spei_rec = '' THEN 
				          LET v_spei_rec = 0; 
				      END IF;
					 
					 
					  ---SE OBTIENE LOS SPEI ENVIADO 	
				   SELECT SUM(monto) 
				     INTO v_spei_env
				     FROM sc_mov_cliente
                    WHERE transaccion = '0274'
                      AND num_cte = v_num_cte;
					  
					   IF v_spei_env IS NULL OR v_spei_env = '' THEN 
				          LET v_spei_env = 0; 
				      END IF;
					 
					 
					 ---SE OBTIENE LAS REMESAS CARGO 	
				   SELECT SUM(monto) 
				     INTO v_rem_cargo
				     FROM sc_mov_cliente
                    WHERE transaccion IN('1110','1140','1325',
										 '1355','1121','1151',
										 '1122','1152','1123')
                      AND num_cte = v_num_cte;
					  
					  
					   IF v_rem_cargo IS NULL OR v_rem_cargo = '' THEN 
				          LET v_rem_cargo = 0; 
				      END IF;
					  
					  
					  
					   ---SE OBTIENE LAS REMESAS ABONO
				   SELECT SUM(monto) 
				     INTO v_rem_abono
				     FROM sc_mov_cliente
                    WHERE transaccion IN('1170','1385','1181','1182')
                      AND num_cte = v_num_cte;
					  
					  
					   IF v_rem_abono IS NULL OR v_rem_abono = '' THEN 
				          LET v_rem_abono = 0; 
				      END IF;
				   
				
                      --- SE OBTIENE LA SUCURSAL				
				   SELECT LIMIT 1(sucursal)
				     INTO v_suc_cuenta
				     FROM sc_mov_cliente
				    WHERE num_cte = v_num_cte;
									 
									 
									 
					--INSERTA VALORES POR CUENTA 						
					if(vsflagentransaccion = 'F') then
						begin work;
						let vsflagentransaccion = 'V';
					end if;
	                INSERT INTO sc_saldos_altos VALUES (v_num_cte,v_suc_cuenta,v_dep_efec,v_retiros,
														v_rem_cargo,v_rem_abono,v_spei_rec,v_spei_env);

					let vicontadorregistros = vicontadorregistros + 1;
					
					if (vicontadorregistros = 500) then
						commit work;
						let vsflagentransaccion = 'F';
						let vicontadorregistros = 0;
						continue foreach;
					end if;
					
					   --LIMPIA VARIABLES
					   LET v_num_cte     = '';
					   LET v_suc_cuenta  = '';
                       LET v_dep_efec    = 0;
                       LET v_retiros     = 0;
                       LET v_rem_cargo   = 0;
                       LET v_rem_abono   = 0;
                       LET v_spei_rec    = 0;
                       LET v_spei_env    = 0;

	 END FOREACH;
     if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
		commit work;
		let vsflagentransaccion = 'F';
     end if;	
		
	     --ELIMINAMOS INDICES   
         --DROP INDEX idx_sc_mov_cliente_tran;
         --DROP INDEX idx_sc_mov_cliente_tran_clie;
         --DROP INDEX idx_sc_mov_cliente_sucursal;
         --DROP INDEX idx_sc_mov_cliente_sup_lim;
		  
		 -- SE OBTIENE LA FECHA PARA ASIGNARSELA AL NOMBRE DEL ARCHIVO
		 LET v_anio_fin = YEAR (v_fecha_hoy);
         LET v_mes_fin  = MONTH(v_fecha_hoy);
         LET v_dia_fin  = DAY  (v_fecha_hoy);
		  
		 IF  LEN (v_mes_fin) = 1 THEN
             LET  v_mes_fin  = 0 || v_mes_fin;
         END IF;

         IF  LEN (v_dia_fin) = 1 THEN
             LET  v_dia_fin  = 0 || v_dia_fin;
         END IF;
		  
		 --ARMA LA FECHA PARA EL NOMBRE DEL ARCHIVO 
         LET v_f_fin = v_dia_fin || v_mes_fin || v_anio_fin ;
		  
		 --PROCESO PARA LA DESCARGA DEL ARCHIVO 
		 LET vsql = '';
         LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                    'UNLOAD TO  /resplogifx/conciliachq/617_REP_MEN_SAL_ALT_PRO_'||v_f_fin||'.txt'||
                    ' SELECT * FROM sc_saldos_altos " >  /resplogifx/conciliachq/consulta.sql';
           
         SYSTEM vsql;
          
         --EJECUCION DEL ARCHIVO .SQL
         LET vsql = '';
         LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/consulta.sql";
         SYSTEM vsql;
		
        IF vCuenta = 1 AND vEstatus=0 THEN
        	BEGIN;
            	UPDATE sc_control_procesos SET estatus = 1 WHERE proceso='sp_saldos_altos' AND fecha= v_pri_dia_mes;
			COMMIT;
        END IF; 		
RETURN  vcodret;
END; 
END PROCEDURE;