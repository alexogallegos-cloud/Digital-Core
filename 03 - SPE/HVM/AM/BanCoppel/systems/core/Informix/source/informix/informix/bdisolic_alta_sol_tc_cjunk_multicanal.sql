CREATE PROCEDURE "informix".alta_sol_tc_cjunk_multicanal(o_empresa CHAR(3),
                                        o_num_cliente              CHAR(20),
                                        o_producto                 CHAR(4),
                                        o_sucursal                 CHAR(4),
                                        o_ejecutivo                CHAR(8),
                                        o_referencia1              CHAR(20),
                                        o_referencia2              CHAR(20),
                                        o_porcentaje               DECIMAL(5,2),
                                        o_situacion                CHAR(1),
                                        o_meses                    SMALLINT,
                                        o_ingreso                  MONEY(14,2),
                                        o_linea                    MONEY(14,2),
                                        o_causa                    SMALLINT,
                                        o_puntualidad              CHAR(2),
                                        o_saldoropa                MONEY(14,2),
                                        o_saldomuebles             MONEY(14,2),
                                        o_saldoprestamos           MONEY(14,2),
                                        o_vencidoropa              MONEY(14,2),
                                        o_vencidomuebles           MONEY(14,2),
                                        o_vencidoprestamos         MONEY(14,2),
                                        o_abonomensualropa         MONEY(14,2),
                                        o_abonomensualmuebles      MONEY(14,2),
                                        o_abonomensualprestamos    MONEY(14,2),
                                        o_ultimacompra             DATE,
                                        o_canal                    CHAR(1))
RETURNING CHAR(5) AS retorno, 
          CHAR(20) AS solicitud;

DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;

DEFINE suc_novalida INTEGER;
DEFINE num_sol      VARCHAR(20);
DEFINE dSucursal    CHAR(4);

DEFINE cEsCivil,
       cGenero,
       --cProfesion,
       cEscolaridad VARCHAR(20);
       
DEFINE scveopcptoelement VARCHAR(120);
DEFINE scveopcpto CHAR(5);

DEFINE cVivienda    CHAR(2);

DEFINE sEsCivil,
       sGenero,
       sProfesion,
       sEscolaridad,
       sVivienda    INTEGER;

-- INC 27 331
DEFINE countSolRT   INTEGER;


LET scod_ret     = '000';
LET vsqlerr      = 0;

LET suc_novalida = 0;
LET num_sol      = '';
LET dSucursal    = '';

LET cEsCivil     = '';
LET cGenero      = '';
--LET cProfesion   = '';
LET cEscolaridad = '';
LET cVivienda    = '';
LET scveopcptoelement ='';
LET scveopcpto ='';

LET sEsCivil     = 0;
LET sGenero      = 0;
LET sProfesion   = 0;
LET sEscolaridad = 0;
LET sVivienda    = 0;

-- INC 27 331
LET countSolRT   = 0;
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret = vsqlerr;
      RETURN TRIM(scod_ret), num_sol;
   END IF;
END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
SELECT  COUNT(*) INTO countSolRT
FROM    bdisolic:"informix".ss_solicitudes
WHERE   numcte = o_num_cliente
AND     num_producto = o_producto
AND     status_solicitud = 'RT';

IF (countSolRT > 0) THEN
    -- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
    SELECT cod_return
    INTO scod_ret
    FROM bdisolic:"informix".ss_catalogo_mensajes
    WHERE empresa = '001'
    AND cod_msj = 'ADN_15';

    RETURN scod_ret,num_sol;
END IF;
-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina

IF o_canal = '8' THEN
    SELECT count(sucursal)
    INTO suc_novalida
    FROM bdinteg:si_sucursales
    WHERE empresa = o_empresa 
    AND sucursal = o_sucursal
    AND tpo_sucursal = 'N';

    IF suc_novalida > 0 THEN
        SELECT sucursal
        INTO dSucursal
        FROM bdinteg:si_cliente
        WHERE numcte = o_num_cliente;

        SELECT count(sucursal)
        INTO suc_novalida
        FROM bdinteg:si_sucursales
        WHERE empresa = o_empresa 
        AND sucursal = dSucursal
        AND tpo_sucursal = 'N';

        IF suc_novalida = 0 THEN
            LET o_sucursal = dSucursal;
        ELSE
            LET o_sucursal = '6700';
        END IF;

    END IF;
END IF;

EXECUTE PROCEDURE bdisolic:alta_sol_tc_cjunk(o_empresa,
                                        o_num_cliente,
                                        o_producto,
                                        o_sucursal,
                                        o_ejecutivo,
                                        o_referencia1,
                                        o_referencia2,
                                        o_porcentaje,
                                        o_situacion,
                                        o_meses,
                                        o_ingreso,
                                        o_linea,
                                        o_causa,
                                        o_puntualidad,
                                        o_saldoropa,
                                        o_saldomuebles,
                                        o_saldoprestamos,
                                        o_vencidoropa,
                                        o_vencidomuebles,
                                        o_vencidoprestamos,
                                        o_abonomensualropa,
                                        o_abonomensualmuebles,
                                        o_abonomensualprestamos,
                                        o_ultimacompra,
                                        '') INTO scod_ret, num_sol;

IF TRIM(scod_ret) <> '000' THEN
	RETURN scod_ret, num_sol;
END IF;


UPDATE bdisolic:ss_solicitudes SET canal_sol = o_canal
WHERE numcte = o_num_cliente AND num_solicitud = num_sol;

---LLenado de parametrico
SELECT estado_civil,sexo,escolaridad,habita_en
INTO cEsCivil,cGenero,cEscolaridad,cVivienda
FROM bdinteg:si_ctepf
WHERE empresa = o_empresa
AND numcte = o_num_cliente;

LET cEsCivil = TRIM(cEsCivil);
LET cEscolaridad = SUBSTR(cEscolaridad,2,1);
--LET cProfesion = TO_CHAR(cProfesion, '&&');

--Estado Civil
SELECT descripcion
INTO cEsCivil
FROM bdinteg:si_edocivil
WHERE clave = cEsCivil;

IF cEsCivil = 'Union Libre' THEN
    LET cEsCivil = 'UniÃ³n Libre';
ELSE
    LET cEsCivil = TRIM(cEsCivil)||'(a)';
END IF;

SELECT elemento
INTO sEsCivil
FROM bdisolic:ss_scoring_element
WHERE empresa = '001'
AND grupo = 3
AND seccion = 2
AND activa = 1
AND descripcion = cEsCivil;

IF sEsCivil != 0 THEN
    INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
    VALUES ('001',2,3,sEsCivil,'01',num_sol,0.00);
END IF;
-----------

-----Genero
IF cGenero = 'M' THEN --M es de Masculino(Hombre).
    LET sGenero = 4;
ELIF cGenero = 'F' THEN --F es Femenino(Mujer).
    LET sGenero = 3;
END IF;

IF sGenero != 0 THEN
    INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
    VALUES ('001',2,2,sGenero,'01',num_sol,0.00);
END IF;
-----------

---Profesion (Ocupacion)
SELECT claveopcionpuesto INTO scveopcpto 
FROM bdinteg:si_ingresos 
WHERE numcte= o_num_cliente 
AND sec_ingreso IN(select MAX(sec_ingreso) from bdinteg:si_ingresos WHERE numcte=o_num_cliente);

IF scveopcpto IN(1,2,3,4,5) THEN
	SELECT descrip INTO scveopcptoelement FROM bdinteg:si_actsubact WHERE id_act = scveopcpto AND id_subact = 0;
ELIF scveopcpto IN(6,7,8,9,10) THEN
	SELECT descrip INTO scveopcptoelement FROM bdinteg:si_actsubact WHERE id_act = scveopcpto AND id_subact = 99;
END IF;

LET scveopcptoelement = substr(scveopcptoelement,1,5);

SELECT elemento
INTO sProfesion
FROM bdisolic:ss_scoring_element
WHERE empresa = '001'
AND grupo = 7
AND seccion = 2
AND activa = 1
AND descripcion like scveopcptoelement || '%';

IF sProfesion != 0 THEN
    INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
    VALUES ('001',2,7,sProfesion,'01',num_sol,0.00);
END IF;
-----------

---Escolaridad
SELECT elemento
INTO sEscolaridad
FROM bdisolic:ss_scoring_element
WHERE empresa = '001'
and grupo = 21
and seccion = 2
AND activa = 1
AND elemento = cEscolaridad;

IF sEscolaridad != 0 THEN
    INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
    VALUES ('001',2,21,sEscolaridad,'01',num_sol,0.00);
END IF;
-----------
---Vivienda
IF cVivienda ='P' THEN LET cVivienda ='5'; 
ELIF cVivienda ='G' THEN LET cVivienda ='6';
ELIF cVivienda ='F' THEN LET cVivienda ='7';
ELIF cVivienda ='R' THEN LET cVivienda ='8';
ELIF cVivienda ='H' THEN LET cVivienda ='9';
ELIF cVivienda ='D' THEN LET cVivienda ='10';
END IF;

SELECT a.elemento
INTO sVivienda
FROM bdisolic:ss_scoring_element a
WHERE a.empresa = '001'
and a.grupo = 5
and a.seccion = 2
AND a.activa = 1
AND a.elemento = cVivienda;

IF NVL(sVivienda,0) != 0 THEN
    INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
    VALUES ('001',2,5,sVivienda,'01',num_sol,0.00);
END IF;
-----------

RETURN scod_ret, num_sol;

END
END PROCEDURE
