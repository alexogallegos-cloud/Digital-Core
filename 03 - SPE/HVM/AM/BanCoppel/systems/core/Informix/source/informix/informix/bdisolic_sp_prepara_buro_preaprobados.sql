CREATE PROCEDURE "informix".sp_prepara_buro_preaprobados( o_empresa CHAR(3), o_numsol CHAR(20))
RETURNING CHAR(6) AS retorno;
                --FRB123
DEFINE scod_ret                 CHAR(6);
DEFINE v_cliente                CHAR(20);
DEFINE v_tpsol                  CHAR(1);
DEFINE cTipoSol                 CHAR(1);
DEFINE sNum_producto            CHAR(4);
DEFINE v_sucursal                       CHAR(4);
DEFINE  cStatusMov              CHAR(1);
DEFINE  cFolioMovil             CHAR(20);
DEFINE  cStatusSol2             CHAR(2);
DEFINE vfecha_sol                   DATE;
DEFINE v_rechazo                CHAR(1);
DEFINE dlinea_min_prod      DECIMAL(18,2);
DEFINE cfamilia             CHAR(3);
DEFINE ctipo_nomina         CHAR(1);
DEFINE cNumSolicitud           CHAR(20);
DEFINE v_hoy                    DATE;
DEFINE vfechaServ DATE;
DEFINE v_SalarioMinimoCoppel    SMALLINT;
DEFINE v_NumSalariosMinimos     INTEGER;
DEFINE v_SituacionPagoCoppel    DECIMAL(5,2);
DEFINE v_meses INTEGER;
DEFINE cOrigenSol                               CHAR(1);
DEFINE v_puntualidad                    CHAR(02);
DEFINE  vsituacion_especial    CHAR(1);     --,
DEFINE  vcausa_situacion                SMALLINT;
DEFINE  o_vencidomuebles INTEGER;
DEFINE  o_vencidoropa    INTEGER;
DEFINE  o_vencidoprestamos INTEGER;
DEFINE  o_abonomuebles   INTEGER;
DEFINE  o_abonoprestamos INTEGER;
DEFINE  o_abonoropa      INTEGER;
DEFINE  o_saldomuebles   INTEGER;
DEFINE  o_saldoropa      INTEGER;
DEFINE  o_saldoprestamos INTEGER;
DEFINE  o_ultimacompra   DATE;
DEFINE  o_vencidoaire             INTEGER;  ---Autor: Jonathan Medina(INICIO)       07/09/2021
DEFINE  o_abonoaire               INTEGER;
DEFINE  o_saldoaire               INTEGER;
DEFINE  o_vencidoafiliados        INTEGER;
DEFINE  o_abonoafiliados          INTEGER;
DEFINE  o_saldoafiliados      INTEGER;
DEFINE  o_vencidoreestructura INTEGER;
DEFINE  o_abonoreestructura   INTEGER;
DEFINE  o_saldoreestructura   INTEGER;
DEFINE  iScorePuntualidad     INTEGER;
DEFINE  cPuntualidadZ             CHAR(3);  ---Autor: Jonathan Medina(FINAL)        07/09/2021
DEFINE  cRegional                 CHAR(3);

DEFINE cTelefono1               CHAR(13);
DEFINE cTelefono2               CHAR(13);
DEFINE cTelefono3               CHAR(13);
DEFINE vsqlerr                  INTEGER;
DEFINE cTipoMov                 CHAR(1);
DEFINE v_habita_en CHAR(10);
DEFINE vedocivil CHAR(10);
DEFINE v_profesion CHAR(10);
DEFINE vElementohabita_en CHAR(10);
DEFINE cSexo CHAR(10);
DEFINE dFechaNac CHAR(15);
DEFINE cEscolaridad CHAR(15);
DEFINE  cSexoBitDet CHAR(10);
DEFINE vescolaridad_des CHAR(100);
DEFINE cRFC_Cte CHAR(15);
DEFINE o_tpingreso SMALLINT;
DEFINE o_periodicidad SMALLINT;
DEFINE o_ingreso DECIMAL(12,2);
DEFINE v_canal CHAR(2);
DEFINE v_bc CHAR(10);
DEFINE v_linea_teorica CHAR(10);
DEFINE cEdad CHAR(10);
DEFINE iEdad SMALLINT;
DEFINE vBuro INTEGER;
DEFINE dVigencia DATE;
DEFINE vSolicitud CHAR(20);
DEFINE vMonto_Aut DECIMAL(14,2);
DEFINE vMonto_Fin DECIMAL(14,2);
DEFINE vFechaDif INTEGER;
DEFINE vfecha_sic DATE;
DEFINE vFolio CHAR(20);
DEFINE vStatus_sol CHAR(2);
DEFINE iContador INTEGER;
DEFINE iCuentaStatus INTEGER;
DEFINE iActividad INTEGER;
DEFINE iSubActividad INTEGER;
DEFINE vAct_Sub CHAR(100);
DEFINE vMontoUdis    DECIMAL(14,2);
DEFINE vCodUdi       CHAR(2);
DEFINE vCodUs        CHAR(2);
DEFINE vClase        CHAR(1);

DEFINE vTpCambioUdi  DECIMAL(14,6);
DEFINE vTpCambioUs   DECIMAL(14,6);

--Valores de bdisolic:ss_cliente_coppel_pp
DEFINE scp_fecha DATE; --
DEFINE scp_puntualidad CHAR(3);
DEFINE scp_meses_historia INTEGER;
DEFINE scp_saldo_total_ropa INTEGER;
DEFINE scp_saldo_total_muebles INTEGER;
DEFINE scp_saldo_total_prestamos INTEGER;
DEFINE scp_vencido_total_ropa INTEGER;
DEFINE scp_vencido_total_muebles INTEGER;
DEFINE scp_vencido_total_prestamos INTEGER;
DEFINE scp_abono_mensual_ropa INTEGER;
DEFINE scp_abono_mensual_muebles INTEGER;
DEFINE scp_abono_mensual_prestamos INTEGER; --
DEFINE scp_situacion_especial CHAR(2);
DEFINE scp_linea_credito INTEGER; --
DEFINE scp_causa smallint;
DEFINE scp_fecha_ultima_compra char(20);
DEFINE scp_fecha_ultimo_pago char(20);
DEFINE scp_prestamo_autorizado char(1);
DEFINE scp_monto_autorizado int8;
DEFINE scp_re_prestamo int8;
DEFINE scp_vencidototalaire integer;
DEFINE scp_abonomensualaire integer;
DEFINE scp_saldototalaire integer;
DEFINE scp_vencidototalafiliados integer;
DEFINE scp_abonomensualafiliados integer;
DEFINE scp_saldototalafiliados integer;
DEFINE scp_vencidototalreestructura integer;
DEFINE scp_abonomensualreestructura integer;
DEFINE scp_saldototalreestructura integer;
DEFINE scp_scorepuntualidad integer;
DEFINE scp_porcentaje_efic integer;
DEFINE vGrupo CHAR(5);
DEFINE cCodRetTDif CHAR(6);  -- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE v_tasa DECIMAL(9,6);
DEFINE v_tasa_mora DECIMAL(9,6);
DEFINE vlIVA decimal (5,3);
DEFINE v_tasasiniva     DECIMAL(9,6);
DEFINE iIdRiesgo INTEGER;
DEFINE v_rowid INTEGER;
DEFINE v_score DECIMAL(14,2);

--Empieza la  inicializacion de datos generales del cliente
LET v_cliente= '';
LET  v_tpsol= '';
LET  cTipoSol='';
LET sNum_producto='';
LET v_sucursal='';
LET cStatusMov='';
LET cFolioMovil='';
LET cStatusSol2='';
LET vfecha_sol= date (1);
LET v_rechazo = '';
LET dlinea_min_prod=0;
LET cfamilia = '';
LET ctipo_nomina = '';
LET cNumSolicitud = '';
LET v_SalarioMinimoCoppel = 0;
LET v_NumSalariosMinimos = '';
LET v_SituacionPagoCoppel = 0;
LET v_meses = 0;
LET cOrigenSol = '';
LET v_puntualidad='';
LET o_vencidomuebles =0;
LET o_vencidoropa    =0;
LET o_vencidoprestamos =0;
LET o_abonomuebles       =0;
LET o_abonoprestamos =0;
LET o_abonoropa      =0;
LET o_saldomuebles   =0;
LET o_saldoropa      =0;
LET o_saldoprestamos =0;
LET o_ultimacompra   = date(1);
LET vsituacion_especial = '';
LET vcausa_situacion = 0;
LET o_vencidoaire             =0;
LET o_abonoaire               =0;
LET o_saldoaire               =0;
LET o_vencidoafiliados        =0;
LET o_abonoafiliados          =0;
LET o_saldoafiliados          =0;
LET o_vencidoreestructura     =0;
LET o_abonoreestructura           =0;
LET o_saldoreestructura           =0;
LET iScorePuntualidad             =0;
LET cTelefono1              = "";
LET cTelefono2                          = "";
LET cTelefono3                          = "";
LET scod_ret                = '000000';
LET vsqlerr                 =0;
LET cTipoMov                ='';
LET cRFC_Cte = '';
LET o_tpingreso            = 5;
LET o_periodicidad         = 0;
LET o_ingreso              = 0;
LET v_canal                = '';
LET v_bc                  = 'BC';

LET vedocivil = '';
LET v_habita_en = '';
LET v_profesion = '';
LET vElementohabita_en = '';
LET cSexo = '';
LET dFechaNac ='';
LET cEscolaridad='';
LET  cSexoBitDet = '';
LET vescolaridad_des = '';
LET v_linea_teorica = '';
LET cEdad = '';
LET iEdad = 0;
LET cRegional = '';
LET vBuro = 0;
LET vSolicitud = '';
LET vMonto_Aut = 0;
LET vMonto_Fin =0;
LET vFechaDif = 0;
LET vFolio ='';
LET vStatus_sol = '';
LET iContador = 0;
LET iCuentaStatus = 0;
LET iActividad = 0;
LET iSubActividad = 0;
LET vAct_Sub = '';
LET vMontoUdis = 0;
LET vCodUdi = '';
LET vCodUs = '';
LET vClase = '';
LET  vTpCambioUdi = 0;
LET  vTpCambioUs  = 0;
--Inicializa Valores de bdisolic:ss_cliente_coppel_pp
LET scp_fecha = date(1);
LET scp_puntualidad = '';
LET scp_meses_historia = 0;
LET scp_saldo_total_ropa = 0;
LET scp_saldo_total_muebles = 0;
LET scp_saldo_total_prestamos = 0;
LET scp_vencido_total_ropa = 0;
LET scp_vencido_total_muebles = 0;
LET scp_vencido_total_prestamos = 0;
LET scp_abono_mensual_ropa = 0;
LET scp_abono_mensual_muebles = 0;
LET scp_abono_mensual_prestamos = 0;
LET scp_situacion_especial  = '';
LET scp_linea_credito = 0;
LET scp_causa = 0;
LET scp_fecha_ultima_compra  = '';
LET scp_fecha_ultimo_pago  = '';
LET scp_prestamo_autorizado  = '';
LET scp_monto_autorizado = 0;
LET scp_re_prestamo = 0;
LET scp_vencidototalaire = 0;
LET scp_abonomensualaire = 0;
LET scp_saldototalaire = 0;
LET scp_vencidototalafiliados = 0;
LET scp_abonomensualafiliados = 0;
LET scp_saldototalafiliados = 0;
LET scp_vencidototalreestructura = 0;
LET scp_abonomensualreestructura = 0;
LET scp_saldototalreestructura = 0;
LET scp_scorepuntualidad = 0;
LET scp_porcentaje_efic = 0;
LET vGrupo = '';
LET cCodRetTDif         = '';
LET v_tasa                      = 0;
LET v_tasa_mora         = 0;
let vlIVA = 0;
LET v_tasasiniva = 0;
LET iIdRiesgo = 3; --canal_sol IN ('6','7');
LET v_rowid=0;
LET v_score=0;


-- Consultar el parametro de vigencias
-- Hacer query del califica por si existe una consulta previa del cliente
-- 1.) No existe consulta Previa : Flujo actual armar y mandar a bc
-- 2.) Ya existe una consulta previa por lo tanto hay que insertar en la ss_solicitudes_sic con todos los datos completos,en este punto puedo hacer una determinacion de credito
-- 3.) Ya existe una consulta previa pero no esta resuelta,hay que insertar con la consulta previa del cliente.

---SET DEBUG FILE TO "/home/e99805965/prepara_buro_ivas.out";
---TRACE ON;

SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy INTO v_hoy FROM bdicred:"informix".sd_fechas WHERE empresa = o_empresa;

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE
        INTO vfechaServ
        FROM sysmaster:sysshmvals;

        IF v_hoy < vfechaServ THEN
                LET v_hoy = vfechaServ;
        END IF;

        BEGIN
                ON EXCEPTION SET vsqlerr
                   IF vsqlerr != 0 THEN
                          LET scod_ret=vsqlerr;
                          RETURN scod_ret;
                   END IF;
           END EXCEPTION;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                SELECT TRIM(valor)  INTO vCodUdi
        FROM bdinteg:si_param
        WHERE empresa = o_empresa AND cod_param = 16;

        SELECT TRIM(valor) INTO vCodUs
        FROM bdinteg:si_param
         WHERE empresa = o_empresa AND cod_param = 17;


                SELECT TRIM(valor) INTO vClase
            FROM bdicred:sd_param WHERE empresa = o_empresa
            AND cod_param = "336";

        EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa,v_hoy,vCodUdi,vClase,'0')
            INTO scod_ret,vTpCambioUdi;

            IF scod_ret<>'00000' THEN
           RETURN scod_ret;
        END IF;

                EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa,v_hoy,vCodUs,vClase,'1')
        INTO scod_ret,vTpCambioUs;

            IF scod_ret<>'00000' THEN
           RETURN scod_ret;
        END IF;

           IF NOT EXISTS (SELECT status_solicitud FROM bdisolic:ss_autorizacion WHERE num_solicitud = o_numsol AND status_solicitud = 'PC' ) THEN
            EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'sistema',o_numsol, 'PC','','Solicitud Pre-Calificada por sistema') INTO scod_ret;
                IF scod_ret <> '000000' THEN
                   LET scod_ret = '000010';
                   RETURN scod_ret;
                END IF;
           END IF;

      SELECT sol.numcte,sol.tipo_solicitud, sol.num_producto,sol.sucursal,sol.status_solicitud,sol.fecha_insert,canal_sol, regional -- Viridiana. Obtiene el producto
          INTO v_cliente,v_tpsol, sNum_producto,v_sucursal,cStatusSol2,vfecha_sol,v_canal, cRegional
      FROM "informix".ss_solicitudes sol
          WHERE sol.empresa = o_empresa
          AND sol.num_solicitud = o_numsol;

          SELECT ingreso_mensual INTO o_ingreso FROM bdisolic:ss_resum_scor_fin WHERE num_solicitud = o_numsol;

          SELECT rechazo_RGC, monto_min_cred, familia, tipo_nomina
          INTO v_rechazo,dlinea_min_prod,cfamilia, ctipo_nomina
          FROM bdicred:"informix".sd_definicion
          WHERE empresa = o_empresa
          AND num_producto = sNum_producto;

      IF cfamilia IN ('001','002','003','004') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN
                        IF cfamilia IN ('001','002','003') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN
                                LET cTipoSol = 'C';
                        ELSE
                                LET cTipoSol = 'T';
                        END IF;

                        SELECT num_solicitud
                                INTO cNumSolicitud
                        FROM "informix".ss_solicitudes
                        WHERE empresa = o_empresa
                        AND numcte  =v_cliente
                        AND tipo_solicitud = cTipoSol
                        AND fecha_insert = v_hoy
                        AND fecha_hora = (SELECT MAX(fecha_hora)
                                                FROM "informix".ss_solicitudes
                                                WHERE empresa = o_empresa
                                                AND numcte  =v_cliente
                                                AND tipo_solicitud = cTipoSol
                                                AND fecha_insert = v_hoy);

                        IF NVL(cNumSolicitud, '') = '' AND TRIM(sNum_producto) = "6500" THEN
                                LET cTipoSol = 'P';

                                SELECT num_solicitud
                                        INTO cNumSolicitud
                                FROM "informix".ss_solicitudes
                                WHERE empresa = o_empresa
                                AND numcte  =v_cliente
                                AND tipo_solicitud = cTipoSol
                                AND fecha_insert = v_hoy
                                AND fecha_hora = (SELECT MAX(fecha_hora)
                                                        FROM "informix".ss_solicitudes
                                                        WHERE empresa = o_empresa
                                                        AND numcte  =v_cliente
                                                        AND tipo_solicitud = cTipoSol
                                                        AND fecha_insert = v_hoy);
                        END IF;

                        IF NVL(cNumSolicitud, '') = '' THEN
                                SELECT num_solicitud_ref
                                        INTO cNumSolicitud
                                FROM "informix".ss_resum_scor_fin
                                WHERE empresa = o_empresa
                                AND num_solicitud = o_numsol;
                        END IF;

                IF NVL(cNumSolicitud,'') ='' THEN
                        LET cNumSolicitud ='';
                        LET cTipoMov ='U';
                ELSE
                        LET cTipoMov ='M';
                END IF;
      END IF;

          IF sNum_producto='6400' THEN
                LET cTipoMov ='U';
          END IF;
                --call bdisolic:"informix".sp_obtienegrupo (o_numsol)RETURNING cCodret2,ptipogrupo,phit;
          SELECT  rfc
                INTO cRFC_Cte
                from bdinteg:si_cliente
                where numcte = v_cliente;

                SELECT LIMIT 1 claveopcionpuesto,clavesubopcionpuesto INTO iActividad,iSubActividad FROM  bdinteg:"informix".si_ingresos WHERE numcte = v_cliente
                AND sec_ingreso IN (SELECT  MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = v_cliente);
                SELECT descrip INTO  vAct_Sub FROM bdinteg:"informix".si_actsubact      WHERE id_act = iActividad AND   id_subact = iSubActividad;

                SELECT LIMIT 1  estado_civil,TRIM(habita_en),TRIM(profesion), DECODE ( TRIM(habita_en), 'P' ,5,'R',8,'F',7,'H',9,'G',6,'D',10), NVL(sexo,"I"), fecha_nac, escolaridad
                INTO vedocivil,v_habita_en,v_profesion, vElementohabita_en,cSexo, dFechaNac, cEscolaridad
                FROM bdinteg:"informix".si_ctepf
                WHERE empresa = o_empresa
                AND numcte = v_cliente;

                SELECT grupo INTO vGrupo FROM bdicred:sd_pre_aprobados_trx WHERE solicitud = o_numsol AND numcte = v_cliente;

                IF vGrupo IS NULL OR vGrupo = '' THEN
                    SELECT grupo INTO vGrupo FROM bdicred:sd_pre_aprobados_his WHERE solicitud = o_numsol AND numcte = v_cliente;
                END IF;

                SELECT LIMIT 1 descripcion      INTO vescolaridad_des FROM bdinteg:si_escolaridad_am WHERE elemento = cEscolaridad;

                LET cSexoBitDet = cSexo;

                UPDATE "informix".ss_resum_scor_fin
                SET ingreso_mensual = o_ingreso,
                  tp_ingreso = o_tpingreso,
                  periodo_ingreso = o_periodicidad,
                  tipo_movimiento = cTipoMov,--RQM 09 279-2
                  num_solicitud_ref  = cNumSolicitud, --RQM 09 279-2
                  linea_tienda = 0
                  --grupo = ptipogrupo mahr-cnbv
                WHERE empresa = o_empresa
                AND num_solicitud = o_numsol;

                SELECT nvl((SELECT telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 1),0),
              nvl((SELECT telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 2),0),
              nvl((SELECT telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 3),0)
                          INTO cTelefono1,cTelefono2,cTelefono3
                FROM bdinteg:"informix".si_cliente a
                WHERE numcte = v_cliente;
        --mahr-cnbv


        UPDATE bdisolic:"informix".ss_revision_determinacion SET ingreso_mensual = o_ingreso, numcte = v_cliente, num_producto = sNum_producto,
                 telefono_domicilio = cTelefono1,telefono_celular = cTelefono2, telefono_trabajo = cTelefono3,grupo = vGrupo
         WHERE empresa = o_empresa AND num_solicitud = o_numsol;

                SELECT valor
                INTO v_SalarioMinimoCoppel
                FROM "informix".ss_param
                WHERE empresa = o_empresa
                AND secuencia = 303;

                IF v_SalarioMinimoCoppel IS NULL THEN
                        LET v_SalarioMinimoCoppel= 0;
                END IF;
                -- Se calcula el numero de Salarios Minimos Coppel que el cliente percibe.
                IF v_SalarioMinimoCoppel >= 0 Then
                        LET v_NumSalariosMinimos= ROUND((o_ingreso / v_SalarioMinimoCoppel),2);
                ELSE
                        LET v_NumSalariosMinimos= 0;
                END IF;
                -- Actualiza el numero de salarios minimos que corresponden al ingreso mensual del cliente
                UPDATE "informix".ss_resum_scor_fin
                SET smbc = v_NumSalariosMinimos
                WHERE empresa = o_empresa
            AND num_solicitud = o_numsol;

                SELECT (EXTEND(current, year to month) - extend(fecha_nac, year to month))
        INTO cEdad
        FROM bdinteg:"informix".si_ctepf
        WHERE numcte = v_cliente;

        LET cEdad = TRIM(cEdad);
        LET iEdad= CAST(cEdad[1,2] AS SMALLINT);

            SELECT NVL(situacion_pago,0),NVL(meses_historia,0),origen, NVL(puntualidad,0),
                       NVL(situacion_credito,0),NVL(causa,0),NVL(vencidoropa,0), NVL(vencidomuebles,0) ,
                           NVL(vencidoprestamos,0),NVL(abonomensualropa,0),NVL(abonomensualmuebles,0),
                           NVL(abonomensualprestamos,0),NVL(saldoropa,0),NVL(saldomuebles,0),NVL(saldoprestamos,0),
                           fecha_ultima_compra, NVL(vencidototalaire,0), NVL(abonomensualaire,0),NVL(saldototalaire,0),NVL(vencidototalafiliados,0),
                           NVL(abonomensualafiliados,0),NVL(saldototalafiliados,0), NVL(vencidototalreestructura,0),NVL(abonomensualreestructura,0),NVL(saldototalreestructura,0),
                           NVL(scorepuntualidad,0),NVL(linea_teorica,0)
            INTO   v_SituacionPagoCoppel,v_meses,           cOrigenSol,  v_puntualidad ,
                       vsituacion_especial,  vcausa_situacion,  o_vencidoropa,o_vencidomuebles,
                           o_vencidoprestamos ,  o_abonoropa ,          o_abonomuebles,
                           o_abonoprestamos ,   o_saldoropa ,           o_saldomuebles ,o_saldoprestamos ,
                           o_ultimacompra, o_vencidoaire, o_abonoaire, o_saldoaire, o_vencidoafiliados,
                           o_abonoafiliados, o_saldoafiliados, o_vencidoreestructura, o_abonoreestructura, o_saldoreestructura, iScorePuntualidad,v_linea_teorica
        FROM "informix".ss_resum_scor_fin
                WHERE empresa= o_empresa AND num_solicitud = o_numsol;

         -- Obtiene TASAS DE INTERES DIFERENCIADAS.             -- INI
                   SELECT iva into vlIVA FROM bdinteg:si_sucursales where sucursal = v_sucursal;

                        EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(o_empresa, o_numsol, '') INTO cCodRetTDif, v_tasa, v_tasa_mora;
                        IF cCodRetTDif <> '000000' OR v_tasa IS NULL THEN
                       LET scod_ret = "453";
                       RETURN TRIM(scod_ret);
                        END IF;


                        SELECT (v_tasa) + (v_tasa * vlIVA), (v_tasa), a.monto_min_cred
                    INTO v_tasa, v_tasasiniva, dlinea_min_prod
                        FROM bdicred:sd_definicion a INNER JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND b.num_solicitud = o_numsol)
                        WHERE a.empresa = o_empresa;

                        SELECT MAX(rowid) INTO v_rowid
                          FROM bdiburo:"informix".br_sc
                          WHERE institucion = 'BC'
                          AND num_cliente= v_cliente
                          AND sc00 <> "004";

                          SELECT sc01::INTEGER
                          INTO v_score
                          FROM bdiburo:"informix".br_sc
                          WHERE rowid =v_rowid
                          AND institucion = 'BC'
                          AND num_cliente = v_cliente AND sc00 <> "004";

                          IF v_score IS NULL THEN
                                 LET v_score = 0;
                          END IF;
                        -- Obtiene TASAS DE INTERES DIFERENCIADAS.              -- FIN

                UPDATE bdisolic:"informix".ss_revision_determinacion
            SET situacion_pago = v_SituacionPagoCoppel ,situacion_credito = vsituacion_especial,meses_historia = v_meses, saldoropa = o_saldoropa, saldomuebles = o_saldomuebles, saldoprestamo = o_saldoprestamos, vencidoropa = o_vencidoropa,
                           vencidomuebles = o_vencidomuebles, vencidoprestamos = o_vencidoprestamos, abonomensualropa = o_abonoropa,
                           abonomensualmuebles = o_abonomuebles, abonomensualprestamos = o_abonoprestamos,  fecha_nacimiento = dFechaNac, profesion = v_profesion,
                           sexo = cSexoBitDet, escolaridad = cEscolaridad,escolaridad_descrip = vescolaridad_des,actividad = iActividad,subactividad = iSubActividad ,actividad_descrip = vAct_Sub,edo_civil = vedocivil, rfc = cRFC_Cte,
                           tipo_cambio_udi = vTpCambioUdi,tipo_cambio_dls = vTpCambioUs,vencidototalaire = o_vencidoaire, abonomensualaire = o_abonoaire, saldototalaire = o_saldoaire, vencidototalafiliados = o_vencidoafiliados, abonomensualafiliados = o_abonoafiliados,
                           saldototalafiliados = o_saldoafiliados, vencidototalreestructura = o_vencidoreestructura, abonomensualreestructura = o_abonoreestructura,
                           saldototalreestructura = o_saldoreestructura, scorepuntualidad = iScorePuntualidad,fecha_sol = vfecha_sol , linea_teorica = v_linea_teorica ,edad = iEdad,
                           tasa = v_tasasiniva,tasa_iva = v_tasa,perfil_riesgo = iIdRiesgo,     bs_score = v_score
            WHERE empresa = o_empresa AND num_solicitud = o_numsol;

                -- No actualiza compromisos de coppel si la consulta a buro se esta realizando desde la bex ya que no se realiza la consulta
                IF EXISTS(SELECT {+INDEX(bdisolic:ss_cliente_coppel_pp rfc_ss_cliente_coppel_pp)} fecha  FROM bdisolic:ss_cliente_coppel_pp WHERE RFC = cRFC_Cte and fecha = DATE(v_hoy)) THEN
                   SELECT LIMIT 1 {+INDEX(bdisolic:ss_cliente_coppel_pp rfc_ss_cliente_coppel_pp)} fecha, puntualidad,porcentaje_efic, meses_historia, saldo_total_ropa, saldo_total_muebles,saldo_total_prestamos, vencido_total_ropa,
                  vencido_total_muebles, vencido_total_prestamos, abono_mensual_ropa, abono_mensual_muebles, abono_mensual_prestamos,
                  situacion_especial, linea_credito,situacion_especial, causa,vencidototalaire,abonomensualaire, saldototalaire, vencidototalafiliados,
                  abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura,
                  scorepuntualidad, fecha_ultima_compra, fecha_ultimo_pago, prestamo_autorizado, monto_autorizado, re_prestamo
                   INTO  scp_fecha, scp_puntualidad, scp_porcentaje_efic,scp_meses_historia, scp_saldo_total_ropa, scp_saldo_total_muebles, scp_saldo_total_prestamos, scp_vencido_total_ropa,
                 scp_vencido_total_muebles, scp_vencido_total_prestamos, scp_abono_mensual_ropa, scp_abono_mensual_muebles, scp_abono_mensual_prestamos,
                 scp_situacion_especial,scp_linea_credito,scp_situacion_especial, scp_causa, scp_vencidototalaire, scp_abonomensualaire, scp_saldototalaire, scp_vencidototalafiliados,
                 scp_abonomensualafiliados, scp_saldototalafiliados, scp_vencidototalreestructura, scp_abonomensualreestructura, scp_saldototalreestructura,
                 scp_scorepuntualidad, scp_fecha_ultima_compra, scp_fecha_ultimo_pago, scp_prestamo_autorizado, scp_monto_autorizado, scp_re_prestamo
                   FROM bdisolic:"informix".ss_cliente_coppel_pp WHERE rfc = cRFC_Cte AND fecha= DATE(v_hoy);

                    IF scp_fecha_ultima_compra = '0000-00-00' THEN
                           LET scp_fecha_ultima_compra = '1900-01-01';
                        END IF;

                    IF scp_fecha_ultimo_pago = '0000-00-00' THEN
                           LET scp_fecha_ultimo_pago = '1900-01-01';
                    END  IF ;

                        UPDATE bdisolic:ss_resum_scor_fin
                        SET puntualidad = scp_puntualidad,
                              linea_tienda = scp_monto_autorizado,
							  situacion_pago = scp_porcentaje_efic,
							  situacion_credito = scp_situacion_especial,				   													
                              meses_historia = NVL(scp_meses_historia,0),
                              saldoropa = scp_saldo_total_ropa,
                              saldomuebles = scp_saldo_total_muebles,
                                  saldoprestamos = scp_saldo_total_prestamos,
                                  vencidoropa = scp_vencido_total_ropa,
                              vencidomuebles = scp_vencido_total_muebles,
                              vencidoprestamos = scp_vencido_total_prestamos,
                              abonomensualropa = scp_abono_mensual_ropa,
                              abonomensualmuebles = scp_abono_mensual_muebles,
							  abonomensualprestamos = scp_abono_mensual_prestamos, 
                              fecha_ultima_compra = TO_DATE(scp_fecha_ultima_compra,"%Y-%m-%d"),
                              fechaultimopago = scp_fecha_ultimo_pago,
                              vencidototalaire = scp_vencidototalaire,
                              abonomensualaire = scp_abonomensualaire,
                              saldototalaire = scp_saldototalaire,
                              vencidototalafiliados = scp_vencidototalafiliados,
                              abonomensualafiliados = scp_abonomensualafiliados,
                              saldototalafiliados = scp_saldototalafiliados,
                              vencidototalreestructura = scp_vencidototalreestructura,
                              abonomensualreestructura = scp_abonomensualreestructura,
                              saldototalreestructura = scp_saldototalreestructura,
                              scorepuntualidad = scp_scorepuntualidad,
                              grupo = vGrupo
                        WHERE  num_solicitud = TRIM(o_numsol);

                        UPDATE bdisolic:"informix".ss_revision_determinacion
                        SET situacion_pago = scp_porcentaje_efic ,
                                situacion_credito = scp_situacion_especial,
                                meses_historia = NVL(scp_meses_historia,0),
                                saldoropa = scp_saldo_total_ropa,
                                saldomuebles = scp_saldo_total_muebles,
                        saldoprestamo = scp_saldo_total_prestamos,
                                vencidoropa = scp_vencido_total_ropa,
                                vencidomuebles = scp_vencido_total_muebles,
                        vencidoprestamos = scp_vencido_total_prestamos,
                                abonomensualropa = scp_abono_mensual_ropa,
                        abonomensualmuebles = scp_abono_mensual_muebles,
                                abonomensualprestamos = scp_abono_mensual_prestamos,
                        fecha_nacimiento = dFechaNac,
                                profesion = v_profesion,
                                linea_tienda = scp_monto_autorizado,
                        sexo = cSexoBitDet,
                                escolaridad = cEscolaridad,
                                edo_civil = vedocivil,
                                rfc = cRFC_Cte,
                        vencidototalaire = scp_vencidototalaire,
                                abonomensualaire = scp_abonomensualaire,
                                saldototalaire = scp_saldototalaire,
                        vencidototalafiliados = scp_vencidototalafiliados,
                                abonomensualafiliados = scp_abonomensualafiliados,
                        saldototalafiliados = scp_saldototalafiliados,
                                vencidototalreestructura = scp_vencidototalreestructura,
                        abonomensualreestructura = scp_abonomensualreestructura,
                                saldototalreestructura = scp_saldototalreestructura,
                                scorepuntualidad = scp_scorepuntualidad,
                                edad = iEdad,
                                tasa = v_tasasiniva,
                                tasa_iva = v_tasa,
                                perfil_riesgo = iIdRiesgo,
                                bs_score = v_score
                  WHERE empresa = o_empresa AND num_solicitud = o_numsol;
                END IF;

            SELECT  insti1 INTO v_bc FROM  bdisolic:ss_canales_solic WHERE canal_solic = v_canal;
            SELECT valor INTO vBuro FROM bdisolic:ss_param WHERE secuencia = 362;

            IF NOT EXISTS (SELECT num_solicitud  FROM bdisolic:"informix".ss_solicitudes_sic WHERE  numcte = v_cliente AND  num_solicitud = o_numsol AND institucion= v_bc) THEN        -- numero de solicitud y x cliente
                INSERT INTO bdisolic:ss_solicitudes_sic(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
                VALUES(o_empresa,v_cliente,o_numsol,o_numsol,v_bc,v_hoy,NULL);

            ELSE
                SELECT COUNT(*) INTO iCuentaStatus FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = o_numsol AND status_solicitud = 'AT';
                SELECT COUNT(*) INTO iContador FROM bdisolic:"informix".ss_solicitudes_sic WHERE  numcte = v_cliente AND  num_solicitud = o_numsol AND institucion= v_bc AND fecha_sic IS  NULL AND folio_bc IS  NULL ;
                IF (iContador >= 1) THEN
                    LET scod_ret = '000006'; -- Se queda con los 4000
                    RETURN scod_ret;
                    END IF;

                SELECT valor INTO vMonto_Aut  FROM bdicred:sd_pre_aprobados_param where codparam=11;
                SELECT linea_final INTO vMonto_Fin FROM bdisolic:"informix".ss_revision_determinacion
                WHERE num_solicitud = o_numsol;

                        IF vMonto_Fin > vMonto_Aut THEN
                       IF iCuentaStatus = 1 THEN
                          EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema',o_numsol, 'AT','ASP','Autorizada') INTO scod_ret;
                       END IF;
                           LET scod_ret = '000005';  -- La linea es mayor a 4000,verificar ss_solicitudes y ss_revision_determinacion
                       RETURN scod_ret;
                        ELSE
                      IF iCuentaStatus = 1 THEN
                         EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema',o_numsol, 'AT','ASP','Autorizada') INTO scod_ret;
                      END IF;

                           LET scod_ret = '000006'; -- Se queda con los 4000
                           RETURN scod_ret;
                        END IF;
           END IF;   -- 1.) Verificar si ya tengo el recalculo de la linea,actualizar linea y regresar control.
                     -- 2.) No tengo recalculo de  de la linea,esperar respuesta de buro si no se dan los 4000.
           IF NOT EXISTS (SELECT status_solicitud FROM bdisolic:ss_autorizacion WHERE num_solicitud = o_numsol AND status_solicitud = 'BC' ) THEN
                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema',o_numsol, 'BC','','En consulta BC') INTO scod_ret;
                IF scod_ret <> '000000' THEN
                        LET scod_ret = '000010';
                        RETURN scod_ret;
                END IF;
           END IF;

           IF NVL(cRegional, '') <> 'APP' THEN
                  EXECUTE PROCEDURE bdiburo:burocred(o_empresa,v_sucursal,'sys_cred',o_numsol,0) INTO scod_ret;
                  IF scod_ret <> '000' THEN
                    LET scod_ret='000011';
                  END IF;
           END IF;
END;
        RETURN scod_ret;

END PROCEDURE
