CREATE PROCEDURE "informix".sp_integracion_cta (p_FechaInicial DATE, p_FechaFinal DATE)
RETURNING CHAR(11) AS r_folio, money(16,2) AS r_monto, CHAR(20) AS r_cuenta, CHAR(16) AS r_tarjeta, CHAR(3) AS r_tipo_evento, CHAR(1) AS r_procede, CHAR(50) AS r_sel_transaccion, DATE AS r_fecha_abon, money(16,2) AS r_monto_abon, DATE AS r_fecha_carg, money(16,2) AS r_monto_carg, money(16,2) AS r_comision, CHAR(30) AS r_concepto;

	/* Definiciï¿½n de variables*/
	DEFINE res_folio 		CHAR(11);
	DEFINE res_monto 		money(16,2);
	DEFINE res_cuenta 		CHAR(20);
	DEFINE res_tarjeta 		CHAR(16);
	DEFINE res_tipo_evento 	CHAR(3);
	DEFINE res_procede		CHAR (1);
	DEFINE res_sel_transa	CHAR(50);
	DEFINE res_fech_abon 	DATE;
	DEFINE res_monto_abon	money(16,2);
	DEFINE res_fecha_cargo	DATE;
	DEFINE res_monto_cargo	money(16,2);
	DEFINE res_comision 	money(16,2);
	DEFINE res_concepto		CHAR(30);
	DEFINE iSqlErr          INTEGER;
	DEFINE tipo_producto	CHAR(2);
	DEFINE p_calculado		CHAR(1);
	DEFINE p_estatus 		CHAR(1);
	DEFINE p_dictamen		DATE;
	DEFINE p_cargo			CHAR(1);

	/* Inicializaciï¿½n de variables*/
	LET res_folio		='';
	LET res_monto		='';
	LET res_cuenta		='';
	LET res_tarjeta		='';
	LET res_tipo_evento	='';
	LET res_procede		='';
	LET res_sel_transa	='';
	LET res_fech_abon	='';
	LET res_monto_abon	='';
	LET res_fecha_cargo	='';
	LET res_monto_cargo	='';
	LET res_comision	='';
	LET res_concepto	='';
	LET tipo_producto   ='';
	LET p_calculado		='';
	LET p_estatus 		='';
	LET p_dictamen		='';
	LET p_cargo			='';

	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET res_folio		='';
				LET res_monto		='';
				LET res_cuenta		='';
				LET res_tarjeta		='';
				LET res_tipo_evento	='';
				LET res_procede		='';
				LET res_sel_transa	='';
				LET res_fech_abon	='';
				LET res_monto_abon	='';
				LET res_fecha_cargo	='';
				LET res_monto_cargo	='';
				LET res_comision	='';
				LET res_concepto	='';

                RETURN res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo,res_monto_cargo,res_comision, res_concepto;

			END IF;
        END EXCEPTION;

		FOREACH
		SELECT b.cargo, a.fky_estatus_aclaracion, date(a.fecha_dictamen), b.calculado, a.folio_csuac,a.importereclamado, c.numero_cuenta, c.numero_tarjeta, b.fky_tipo_evento, a.procede, d.descripcion as seleccion_transaccion, CASE WHEN b.cargo='0' THEN date(b.fecha_afectacion) END as fech_abon, CASE WHEN b.cargo='0' THEN b.montoprocedente END as monto_aplicado, CASE WHEN b.cargo='1' THEN date(b.fecha_afectacion) END as fec_carg, CASE WHEN b.cargo='1' and b.numero_transaccion not in ('0343','5212') THEN b.montoprocedente END as cargo_aplicado, '' as comision ,  DECODE(a.procede,1,'Dictamen procedente',0,'Dictamen no procedente',null,'Abono temporal') as concepto
			INTO p_cargo, p_estatus, p_dictamen, p_calculado, res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto
		FROM acl_aclaracion a, acl_movimiento b, acl_producto c, outer acl_tipo_catalogo_transaccion d
		WHERE a.folio_csuac=b.folio_csuac
			AND b.fky_producto=c.pky_producto
			AND b.fky_tipo_catalogo_transaccion=d.pky_tipo_catalogo_transaccion
			AND b.exitoso='1'
			AND date(b.fecha_afectacion) between p_FechaInicial and p_FechaFinal
			AND b.numero_transaccion not in ('0343','5212')
			order by b.folio_csuac, b.pky_movimiento,b.fecha_afectacion

			IF (p_estatus='2') THEN
				LET res_concepto='Abono temporal';
			END IF;
			IF (p_estatus>'2') THEN
				IF (p_dictamen <> res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Abono temporal';
				ELSE IF (p_dictamen=res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Dictamen Procede';
					END IF;
				END IF;

				IF (p_dictamen=res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
				ELSE IF (p_dictamen<>res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
					END IF;
				END IF;
			END IF;

			LET tipo_producto=SUBSTRING(res_cuenta FROM 0 FOR 3);

			IF ((SELECT procede FROM "informix".acl_aclaracion WHERE folio_csuac =res_folio)=0 and p_calculado=0 ) THEN -- SE debe reflejar sobre el cargo del abono temporal
				IF (tipo_producto in ('13','14','17')) THEN
					LET res_comision='0.00';
				ELSE
					SELECT monto*1.16  INTO res_comision FROM "informix".acl_movimiento WHERE folio_csuac=res_folio and numero_transaccion in ('0343','5212');
				END IF;
			END IF;

			RETURN res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto WITH RESUME;
		END FOREACH;

	END

END PROCEDURE
DOCUMENT
'SP para cumplimiento de RQM 06 306 Integraciï¿½n de cuenta contable ? abonos temporales',
'Genera reporte de afectaciones a cuentas de los clientes',
'Autor: Bernardo Beltrï¿½n Herrera - Gerencia: Mtto 2',
'Coordinaciiï¿½n: 22 Sistemas Administrativos y Perifï¿½ricos',
'Fecha de creaciï¿½n: 12/11/2014',
'Versiï¿½n: 0.9',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_integracion_cuenta (p_FechaInicial DATE, p_FechaFinal DATE)
RETURNING CHAR (5);

	/* Definicion de variables*/
	DEFINE res_folio 		CHAR(11);
	DEFINE res_monto 		money(16,2);
	DEFINE res_cuenta 		CHAR(20);
	DEFINE res_tarjeta 		CHAR(16);
	DEFINE res_tipo_evento 	CHAR(3);
	DEFINE res_procede		CHAR (1);
	DEFINE res_sel_transa	CHAR(50);
	DEFINE res_fech_abon 	DATE;
	DEFINE res_monto_abon	money(16,2);
	DEFINE res_fecha_cargo	DATE;
	DEFINE res_monto_cargo	money(16,2);
	DEFINE res_comision 	money(16,2);
	DEFINE res_concepto		CHAR(30);
	DEFINE iSqlErr          INTEGER;
	DEFINE tipo_producto	CHAR(2);
	DEFINE p_calculado		CHAR(1);
	DEFINE p_estatus 		CHAR(1);
	DEFINE p_dictamen		DATE;
	DEFINE p_cargo			CHAR(1);
	DEFINE vcodret			char(5);
	DEFINE vsqlerr			integer;
	DEFINE  vsql        	char(3000);

	/* Inicializacion de variables*/
	LET res_folio		='';
	LET res_monto		='';
	LET res_cuenta		='';
	LET res_tarjeta		='';
	LET res_tipo_evento	='';
	LET res_procede		='';
	LET res_sel_transa	='';
	LET res_fech_abon	='';
	LET res_monto_abon	='';
	LET res_fecha_cargo	='';
	LET res_monto_cargo	='';
	LET res_comision	='';
	LET res_concepto	='';
	LET tipo_producto   ='';
	LET p_calculado		='';
	LET p_estatus 		='';
	LET p_dictamen		='';
	LET p_cargo			='';


--Verificar tablas fisicas
		IF EXISTS( SELECT * FROM systables WHERE tabname ='acl_integracion_cta') THEN
			DROP TABLE "informix".acl_integracion_cta;
		END IF;

	--creacion de tabla
        CREATE  TABLE  "informix".acl_integracion_cta
            (folio           CHAR(11),
             monto           money,
            cuenta           char(20),
            tarjeta          char(16),
            tipo_evento      char(3),
            procede          char(1),
            sel_transac      char(50),
            fecha_abono      date,
            monto_abono      money,
            fecha_cargo      date,
            monto_cargo      money,
            comision         money,
            concepto         char(30)
		)  extent size 362695 next size 36484 lock mode row;

	let vcodret = "";
	let vsqlerr = 0;

	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/acl_integracion_cta.out"; 
    --TRACE ON;

	BEGIN

		On exception set vsqlerr
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;

	SET ISOLATION TO DIRTY READ;

		FOREACH
		SELECT b.cargo, a.fky_estatus_aclaracion, date(a.fecha_dictamen), b.calculado, a.folio_csuac,a.importereclamado, c.numero_cuenta, c.numero_tarjeta, b.fky_tipo_evento, a.procede, d.descripcion as seleccion_transaccion, CASE WHEN b.cargo='0' THEN date(b.fecha_afectacion) END as fech_abon, CASE WHEN b.cargo='0' THEN b.montoprocedente END as monto_aplicado, CASE WHEN b.cargo='1' THEN date(b.fecha_afectacion) END as fec_carg, CASE WHEN b.cargo='1' and b.numero_transaccion not in ('0343','5212') THEN b.montoprocedente END as cargo_aplicado, '' as comision ,  DECODE(a.procede,1,'Dictamen procedente',0,'Dictamen no procedente',null,'Abono temporal') as concepto
			INTO p_cargo, p_estatus, p_dictamen, p_calculado, res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto
		FROM acl_aclaracion a, acl_movimiento b, acl_producto c, outer acl_tipo_catalogo_transaccion d
		WHERE a.folio_csuac=b.folio_csuac
			AND b.fky_producto=c.pky_producto
			AND b.fky_tipo_catalogo_transaccion=d.pky_tipo_catalogo_transaccion
			AND b.exitoso='1'
			AND date(b.fecha_afectacion) between p_FechaInicial and p_FechaFinal
			AND b.numero_transaccion not in ('0343','5212')
			order by b.folio_csuac, b.pky_movimiento,b.fecha_afectacion

			IF (p_estatus='2') THEN
				LET res_concepto='Abono temporal';
			END IF;
			IF (p_estatus>'2') THEN
				IF (p_dictamen <> res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Abono temporal';
				ELSE IF (p_dictamen=res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Dictamen Procede';
					END IF;
				END IF;

				IF (p_dictamen=res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
				ELSE IF (p_dictamen<>res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
					END IF;
				END IF;
			END IF;

			LET tipo_producto=SUBSTRING(res_cuenta FROM 0 FOR 3);

			IF ((SELECT procede FROM "informix".acl_aclaracion WHERE folio_csuac =res_folio)=0 and p_calculado=0 ) THEN -- SE debe reflejar sobre el cargo del abono temporal
				IF (tipo_producto in ('13','14','17')) THEN
					LET res_comision='0.00';
				ELSE
					SELECT monto*1.16  INTO res_comision FROM "informix".acl_movimiento WHERE folio_csuac=res_folio and numero_transaccion in ('0343','5212');
				END IF;
			END IF;

			INSERT INTO  "informix".acl_integracion_cta values (res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto);
		END FOREACH;

		let vcodret="00002";

		--Generacion de archivo reporte
			let vsql = ' echo "Folio_CSUAC|Importe_Reclamado|Numero_De_Cuenta|Tarjeta|Tipo_Evento|Procede|Seleccion_Transaccion|Fecha_Afectacion(ABONO_A_CLIENTE)|Monto_Aplicado(ABONO_A_CLIENTE)|Fecha_Afectacion(CARGO_A_CLIENTE)|Monto_No_Procedente(CARGO_A_CLIENTE)|Comision_por_no_procedente(CARGO_A_CLIENTE)|Concepto">/resplogifx/repaclaraciones/RPT_integracion_cta_contable_'||LPAD (day(today-1),2,"0")||LPAD (MONTH(today-1),2,"0")||year(today-1)||'.unl';
			system vsql;
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/repaclaraciones/acl_integracion_cta.unl  select folio, monto, cuenta, tarjeta, tipo_evento, procede, sel_transac, fecha_abono, monto_abono, fecha_cargo, monto_cargo, comision, concepto  from acl_integracion_cta;">/resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdiaclaracion  /resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/repaclaraciones/acl_integracion_cta.unl >>/resplogifx/repaclaraciones/RPT_integracion_cta_contable_"||LPAD (day(today-1),2,"0")||LPAD (MONTH(today-1),2,"0")||year(today-1)||".unl";
			system vsql;
			let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.unl';
			system vsql;


		let vcodret="00000";

		return vcodret;

	END

END PROCEDURE
DOCUMENT
'SP para cumplimiento de RQM 06 306 Integracion de cuenta contable abonos temporales',
'Genera reporte de afectaciones a cuentas de los clientes',
'Autor: Bernardo Beltran Herrera - Gerencia: Mtto 2',
'Coordinacion: 22 Sistemas Administrativos y Perifericos',
'Fecha de creacion: 12/11/2014',
'Version: 0.9',
'BD: bdiaclaracion',

'Se modifica SP para corregir error que se presentaba al momento de generar los archivos',
'10/08/2016',
'Adilene Lara Armenta';

CREATE PROCEDURE "informix".sp_acl_regulatorio27 (pFechaCap_Ini DATE,pFechaCap_Fin DATE)

	RETURNING CHAR(5);

-- ****************************************************************************
-- DefiniciÃ³n de Variables de datos 
-- ****************************************************************************

	DEFINE CodRet                        CHAR(5);
    define icontador                     integer;
	DEFINE v_folio_csuac                 VARCHAR (11);                    
	DEFINE v_fechacaptura                DATE;                            
	DEFINE v_importereclamado            MONEY;                           
	DEFINE v_fky_estatus_aclaracion      INTEGER;                         
	DEFINE v_fecha_dictamen              DATEtime YEAR to FRACTION(5);    
	DEFINE v_montoprocedente             MONEY;                           
	DEFINE v_fky_tipo_codigo_resolucion  INTEGER;                         
	DEFINE v_procede					 SMALLINT;                        
	DEFINE v_fky_producto                INTEGER;                         
	DEFINE v_fky_tipo_evento             INTEGER;                         
	DEFINE v_fky_estatus_corp_general    INTEGER;                         
	DEFINE v_fechahora                   DATEtime YEAR to FRACTION(5);    
	DEFINE v_fecha_abono                 DATEtime YEAR to FRACTION(5);  
	DEFINE v_fky_tipo_producto           INTEGER;                         
	DEFINE v_numero_cuenta               VARCHAR (20);                    
	DEFINE v_numero_tarjeta              VARCHAR (16);                    
	DEFINE v_pky_tipo_producto 			 INTEGER;                         
	DEFINE v_des_tipo_producto			 VARCHAR (255);	                  
	DEFINE v_origen_evento               INTEGER;                         
	DEFINE v_pky_tipo_evento			 INTEGER;                         
	DEFINE v_desc_evento                 VARCHAR (50);                    
	DEFINE v_desc_origen                 VARCHAR (50);                    
	DEFINE v_desc_aclaracion			 VARCHAR (255);                   
	DEFINE v_pky_estatus_corporativo	 INTEGER;                         
	DEFINE v_codigo_resolucion           VARCHAR (4);                     
	DEFINE v_desc_resolucion             VARCHAR (255);                     
	DEFINE v_importe_rec                 MONEY;                           
	DEFINE v_quebranto_inst              MONEY;                           
	DEFINE v_transaccion_quebranto       INTEGER;
	DEFINE v_folio_csuac_r27             VARCHAR (11);                    
	DEFINE v_fky_estatus_aclaracion_r27  INTEGER;
	
	DEFINE v_tipo_procedente			 INTEGER;
	
	DEFINE v_fecha_inicio_min            DATE;
	DEFINE v_fecha_inicio                DATE;                             
	DEFINE v_fecha_fin                   DATE;   

	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/resplogifx/traces/IAP/SPR27";
--TRACE ON;
	
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
	
	LET CodRet                            = '00000';
	
	LET v_folio_csuac                     = '';
	LET v_fechacaptura                    = '';
	LET v_importereclamado                = '';
	LET v_fky_estatus_aclaracion          = 0 ;
	LET v_fecha_dictamen                  = '';
	LET v_montoprocedente                 = '';
	LET v_fky_tipo_codigo_resolucion      = 0 ;
	LET v_procede                         = 0 ;
	LET v_fky_producto                    = 0 ;
	LET v_fky_tipo_evento                 = 0 ;
	LET v_fky_estatus_corp_general        = 0 ;
	LET v_fechahora                       = '';
	LET v_fecha_abono                     = '';
	LET v_numero_cuenta                   = '';
	LET v_numero_tarjeta                  = '';
	LET v_pky_tipo_producto               = 0 ;
	LET v_des_tipo_producto               = '';
	LET v_origen_evento                   = 0 ;
	LET v_pky_tipo_evento                 = 0 ;
	LET v_desc_evento                     = '';
	LET v_desc_origen                     = '';
	LET v_desc_aclaracion                 = '';
	LET v_pky_estatus_corporativo         = '';
	LET v_codigo_resolucion               = '';
	LET v_desc_resolucion                 = '';
    LET v_importe_rec                     = '';    
    LET v_quebranto_inst                  = '';
	LET v_transaccion_quebranto           = 0 ;
	LET v_folio_csuac_r27                 = '';
	LET v_fky_estatus_aclaracion_r27      = 0 ;
	
	LET v_tipo_procedente                 = 0 ;

	LET v_fecha_inicio_min                = '';            -- Fecha para inicio de bÃºsqueda por aclaraciÃ³n activa mÃ¡s antigua.               
	LET v_fecha_inicio                    = pFechaCap_Ini;                           
	LET v_fecha_fin                       = pFechaCap_Fin;
	LET icontador=0;

-->> Fecha mas antigua con aclaraciones con estatus de ingresadas

	SELECT MIN (fechacaptura) 
	INTO v_fecha_inicio_min
	FROM acl_aclaracion 
	WHERE fky_estatus_aclaracion = 2;

BEGIN WORK;
FOREACH WITH HOLD

	-- select * from acl_aclaracion                                             -- A
	SELECT 
	folio_csuac, fechacaptura, importereclamado, fky_estatus_aclaracion, fecha_dictamen, montoprocedente, fky_tipo_codigo_resolucion, procede
	,fky_producto, fky_tipo_evento, fky_estatus_corp_general
	INTO 
	v_folio_csuac, v_fechacaptura, v_importereclamado, v_fky_estatus_aclaracion, v_fecha_dictamen, v_montoprocedente, v_fky_tipo_codigo_resolucion, v_procede
	,v_fky_producto, v_fky_tipo_evento, v_fky_estatus_corp_general
	FROM acl_aclaracion a
	WHERE (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fky_estatus_aclaracion > 1 AND fechacaptura BETWEEN pFechaCap_Ini AND pFechaCap_Fin AND folio_csuac IS NOT NULL)  -->> Ingresadas en el periodo
	OR    (fechacaptura >= v_fecha_inicio_min AND fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND fky_estatus_aclaracion in (2))            -->> Sin resolver en el periodo
	OR    (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND DATE(fecha_dictamen) BETWEEN pFechaCap_Ini AND pFechaCap_Fin)	                 -->> Resultas en el periodo
	
	-->> select * from acl_movimiento												-- B 
	SELECT fechahora AS fecha_mov_original, fecha_afectacion as fecha_abono
	INTO v_fechahora, v_fecha_abono
	FROM acl_movimiento
	WHERE folio_csuac = v_folio_csuac
	AND fky_padre IS NULL
	AND duplicado = 0; 																--> ValidaciÃ³n de movimientos duplicados 11/03/2013

	SELECT b.quebranto_transaccion AS transaccion_quebranto
	INTO v_transaccion_quebranto
	FROM acl_movimiento a, acl_tipo_catalogo_transaccion b
	WHERE b.pky_tipo_catalogo_transaccion = a.fky_tipo_catalogo_transaccion 
    AND a.folio_csuac = v_folio_csuac
	AND a.fky_padre IS NULL
    AND b.quebranto_transaccion = 1 ;

	-- >> select * from acl_producto												-- C
	SELECT fky_tipo_producto, numero_cuenta, numero_tarjeta
	INTO v_fky_tipo_producto, v_numero_cuenta, v_numero_tarjeta
	FROM acl_producto 
	WHERE pky_producto = v_fky_producto;

	-- >> select * from acl_tipo_producto											-- C.C
	SELECT pky_tipo_producto, descripcion
	INTO v_pky_tipo_producto, v_des_tipo_producto
	FROM acl_tipo_producto
	WHERE pky_tipo_producto = v_fky_tipo_producto;
	
	-->> select * from acl_tipo_evento                                              -- D
	SELECT fky_origen_evento, pky_tipo_evento, descripcion as desc_evento
	INTO v_origen_evento, v_pky_tipo_evento, v_desc_evento
	FROM acl_tipo_evento
	WHERE pky_tipo_evento = v_fky_tipo_evento;
	
	-->> select * from acl_origen_evento                                            -- E
	SELECT descripcion as desc_origen_evento
	INTO v_desc_origen
	FROM acl_origen_evento
	WHERE pky_origen_evento = v_origen_evento;
	
	-->> select * from acl_estatus_aclaracion                                       -- F
	SELECT descripcion as desc_aclaracion
	INTO v_desc_aclaracion
	FROM acl_estatus_aclaracion
	WHERE pky_estatus_aclaracion = v_fky_estatus_aclaracion;
	
	-->> select * from acl_estatus_corporativo                                      -- G
	SELECT pky_estatus_corporativo
	INTO v_pky_estatus_corporativo
	FROM acl_estatus_corporativo
	WHERE pky_estatus_corporativo = v_fky_estatus_corp_general;
	
	-->> select * from acl_tipo_codigo_resolucion                                   -- H
	SELECT codigo_resolucion, descripcion as desc_resolucion, tipo_procedente
	INTO v_codigo_resolucion, v_desc_resolucion, v_tipo_procedente
	FROM acl_tipo_codigo_resolucion
	WHERE pky_tipo_codigo_resolucion = v_fky_tipo_codigo_resolucion;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n no duplicar aclaraciones dictaminadas y ya reportadas.
	
	SELECT folio_csuac, fky_estatus_aclaracion
	INTO v_folio_csuac_r27, v_fky_estatus_aclaracion_r27
	FROM acl_regulatorio27 
	WHERE folio_csuac = v_folio_csuac 
	AND fky_estatus_aclaracion in(3,4,5);
	
	IF v_fky_estatus_aclaracion_r27 in (3,4,5) THEN 

		CONTINUE FOREACH;
	
	END IF;
				
		--CONTINUE FOREACH;
		
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto recuperados -- ok

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_transaccion_quebranto <> 1 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac;

    END IF;

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_fky_estatus_corp_general <> 19 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac 
		AND v_procede = 1; -- ValidaciÃ³n para finalizadas

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por abono sin autorizaciÃ³n -- ok

    IF v_fky_estatus_aclaracion IN (3,4,5) AND v_fky_estatus_corp_general = 19 THEN

        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion a
        WHERE folio_csuac = v_folio_csuac;

        SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '653';

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por selecciÃ³n de transacciÃ³n -- ok

    IF v_transaccion_quebranto = 1 THEN
    
        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion
        WHERE folio_csuac = v_folio_csuac;

    END IF;

--- >> Formateo de Campos

    IF v_quebranto_inst IS NULL THEN    -- ValidaciÃ³n de monto quebrantado para que no se coloque en null
        LET v_quebranto_inst = 0;
    END IF;

    IF v_montoprocedente IS NULL THEN   -- ValidaciÃ³n de monto procedente para que no se coloque en null
        LET v_montoprocedente = 0;
    END IF;

    IF v_importe_rec IS NULL THEN       -- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_importe_rec = 0;
    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aclaraciones Concluidas sin Procede a favor del cliente por Abono sin AutorizaciÃ³n -- ok
	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_procede IS NULL AND v_fky_estatus_corp_general = 19 THEN
	
	LET v_procede = 1 ; -- Abono a favor del Cliente
	
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito
{	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) THEN
	
	SELECT SUM (monto) 
	INTO v_importereclamado
	FROM acl_movimiento WHERE folio_csuac = v_folio_csuac;
		
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito Procedentes

	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) AND v_procede = 1 AND v_montoprocedente <> v_importe_rec THEN
	
	LET v_montoprocedente = v_importe_rec ;
		
	END IF;-
}	

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n Aclaraciones pendientes y/o concluidas despuÃ©s de el periodo a reportar no mostrar datos innecesarios
	 IF v_fky_estatus_aclaracion = 2 OR DATE (v_fecha_dictamen) > pFechaCap_Fin THEN -- Agregada
	    SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '654';

		LET v_montoprocedente 	= 0;    -- ValidaciÃ³n de monto procedente para que no se coloque en null    
        LET v_importe_rec 		= 0;	-- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_quebranto_inst 	= 0;	-- ValidaciÃ³n de monto quebrantado para que no se coloque en null
		LET v_fecha_abono 		= '';
		LET v_fecha_dictamen	= ''; 	-- Agregada
		LET v_procede 			= ''; 	-- Agregada 
		
			IF v_fky_estatus_aclaracion > 2 THEN 
			
				SELECT descripcion as desc_aclaracion  
				INTO v_desc_aclaracion				-- Cambiar la descripciÃ³n de estatus de la aclaraciÃ³n a Ingresada
				FROM acl_estatus_aclaracion
				WHERE pky_estatus_aclaracion = 2;	
				
				LET v_fky_estatus_aclaracion = 2;	-- Cambiar estatus de la aclaraciÃ³n a 2
			
			END IF;

    END IF;

	
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Adecuaciones para aclaraciones correspondientes a productos '1900' y '2200' para capturarlos como "Cuentas de Cheques" por peticiÃ³n de usuario 24/09/2014 <<<<<<<<<<<<<
IF (SUBSTR (v_numero_cuenta , 0, 4) IN ('1900', '2200') AND v_numero_tarjeta = '' OR v_numero_tarjeta IS NULL) THEN
	LET v_pky_tipo_producto = 4;
	LET v_des_tipo_producto = 'Cuentas de Cheques';
END IF;
--------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO acl_regulatorio27
	VALUES (v_folio_csuac, v_fechacaptura, v_fechahora, v_numero_cuenta, v_numero_tarjeta, v_pky_tipo_producto, 
	v_des_tipo_producto, v_origen_evento, v_desc_origen, v_pky_tipo_evento, v_desc_evento, v_importereclamado, v_fky_estatus_aclaracion, 
	v_desc_aclaracion, v_procede, v_fecha_dictamen, v_fecha_abono, v_codigo_resolucion, v_desc_resolucion, v_montoprocedente, 
	v_importe_rec, v_quebranto_inst, v_fecha_inicio, v_fecha_fin, current);
	
	LET iContador = iContador + 1;
    IF iContador= 1000 THEN COMMIT WORK;
    LET iContador=0;
    BEGIN WORK;
    END IF;

END FOREACH

LET iContador=0;

-- No es posible convertir entre los tipos especificados
	
	--UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;

	LET CodRet = '00000';
	
	RETURN CodRet;
	
END PROCEDURE;