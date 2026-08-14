CREATE PROCEDURE "informix".sp_gen_arch_movimientos() RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar archivo de movimientos para los registros de bei_consulta_mov
-- AUTOR : Jose Leon Arellano
-- FECHA : 11/Julio/2016
-- BD: bdibei
-- FECHA DE LIBERACION: 29/Julio/2016
-- FECHA DE MODIFIACION: 18/Agosto/2016

-- MODIFICACION: se modifica para incluir mas detalle en la consulta de abono SPEI
-- FECHA DE MODIFIACION: 01/JULIO/2019
-- PERSONA QUE MODIFICA: Berenice Noriega Guevara

-- MODIFICACION: Se modifica el ORDER de los queries de movimientos a solo fecha y serial
-- PERSONA QUE MODIFICA: Marco Tinajero - BanCoppel - Internet.
-- FECHA DE MODIFIACION: 16/Marzo/2022

-- MODIFICACION: Ajuste en los queries para detalles de SPEI agregando fecha del movimiento y beneficiario como filtros para evitar duplicaciones de claves
-- PERSONA QUE MODIFICA: Marco Tinajero - BanCoppel - Internet.
-- FECHA DE MODIFIACION: 09/Mayo/2022

--Modificacion: Se modifica el ORDER de los queries de movimientos a solo fecha y hora, debido a un descuadre del ID SERIAL
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 08 Diciembre 2022

--Modificacion: A solicitud de usuario, se reversa el cambio del 8 de Diciembre porque no resolv o el problema de ordenamiento de raiz
--Modifico: Armando Barrientos - BanCoppel - Internet.
--FechaMod: 14 Diciembre 2022

--Modificacion: Se modifica el tiempo para la depuracion de archivos de movs con 2 o m s dias aplazandolo a 7 dias
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 27 Marzo 2023

--Modificacion: Se agrega a los queries de obtencion de referencias de transacciones 0273 los filtros de estatus de envio <> C y clave tipo de pago <> 0
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 01 Julio 2025
--INC 03 501 EmpresaNet - Optimizacion Generacion Archivo de Movimientos

--Modificacion: Se actualiza el numero de serie por reset de num_serie
--Modifico: Luis Baldivia - Luis David Espinoza - BanCoppel - Internet.
--FechaMod: 14 Octubre 2025
--INC 03 518 EmpresaNet - Problema de consulta de movimientos 7 y 8 de octubre 25 Desborde de num serie

--Modificacion: Se actualiza la consulta para excluir resversos
--Modifico: Luis Baldivia - BanCoppel - Internet.
--FechaMod: 11 noviembre 2025
--****************************************************************************************************

-- Definicion de variables
    DEFINE vStatus CHAR(3);
    DEFINE vFolio CHAR(25);
    DEFINE vTotalReg BIGINT;
    DEFINE vDiferencia INTEGER;
-- Variables para consulta de movimientos
    DEFINE vEmpresa CHAR(3);
    DEFINE vCuenta CHAR(20);
    DEFINE xFecha CHAR(10);
    DEFINE vFinicial DATE;
    DEFINE vFfinal DATE;
    DEFINE vFechaDia DATE; -- Limite para movimientos del movdia
    DEFINE vFechaHis DATE; -- Limite para movimientos de movhis
    DEFINE vFechaOld DATE; -- Limite para movimientos de movhis_old
    DEFINE vFechaOld2 DATE; -- Limite para movimientos de movhis_old2
    DEFINE vDescripcionSpei CHAR(40);
    DEFINE vPath CHAR(200);

-- Variables para el insert
    DEFINE vfecha DATE;
    DEFINE vcontador INTEGER;
    DEFINE vcuantos1 INTEGER;
    DEFINE vfech_alt DATE;
    DEFINE vfech_hor DATETIME HOUR to FRACTION (3);
    DEFINE vnumero CHAR(4);
    DEFINE vnaturaleza CHAR(4);
    DEFINE vsdo_cuenta MONEY(15,2);
    DEFINE vmonto_tot MONEY(15,2);
    DEFINE vDescripcion  CHAR(40);
    DEFINE vreferencia CHAR(140);  ---pasamos de 40 a 140
    DEFINE vnumcuenta CHAR(20);
    DEFINE vtransacc_suc CHAR(4);
    DEFINE vtransacc CHAR(4);
    DEFINE vcomienza        INTEGER;
    DEFINE vcuantos                 INTEGER;
    DEFINE vregistros INTEGER;
    DEFINE vvchrnombrecorto CHAR(20); --para abono spei
    DEFINE vvchrcuentaord CHAR(20); --para abono spei
    DEFINE vvchrnombreord CHAR(40); --para abono spei
    DEFINE vvchrconceptopago2 CHAR(40); --para abono spei
    DEFINE vnum_serial BIGINT;

-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE vChrCodRetDepuracion CHAR(5);

    LET cod_ret  = '00000';
    LET vEmpresa = '001';

    LET vcontador = -1;
    LET vcuantos = 0;
    LET vcomienza   = -1;
    LET vregistros = 1000;

   -- set debug file to "/home/informix/BereniceOut/sp_gen_arch_movimientos.out";
   -- Trace on;

    BEGIN
        -- Manejo de excepcion
        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET cod_ret = sql_err;
                RETURN cod_ret;
            END IF ;
        END EXCEPTION;


        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- Consulta fecha de hoy
        -- Se elimina la Directiva debido a la esta Tabla solo contiene 1 registro SELECT  {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)} fecha_hoy
        SELECT fecha_hoy
		INTO vFechaDia
        FROM bdicheq:"informix".sc_fechas;

        --#### Quitar
        --let vFechaDia = today-20;

        -- Obtener fecha limite de historico
        SELECT --TO_DATE(valor, '%m/%d/%Y')    INTO vFechaHis
        valor INTO  xFecha
        FROM bdicheq:"informix".sc_param
        WHERE empresa = vEmpresa
        AND codparam = 'fechcon_movhis';
	
        IF LEN(xFecha) ='8' THEN
            LET vFechaHis =  TO_DATE(xFecha, '%m%d%Y');
        ELSE
            LET vFechaHis =  TO_DATE(xFecha, '%m/%d/%Y');
        END IF;
	
		-- Obtener fecha limite de historico old
        SELECT --TO_DATE(valor, '%m/%d/%Y')    INTO vFechaOld
        valor INTO  xFecha
        FROM bdicheq:"informix".sc_param
        WHERE empresa = vEmpresa
        AND codparam = 'FechIniCon_movhis_ol';
	
        IF LEN(xFecha) ='8' THEN
            LET vFechaOld =  TO_DATE(xFecha, '%m%d%Y');
        ELSE
            LET vFechaOld =  TO_DATE(xFecha, '%m/%d/%Y');
        END IF;

        -- Obtener fecha limite de historico old 2
        SELECT --TO_DATE(valor, '%m/%d/%Y') INTO vFechaOld2
        valor INTO  xFecha
        FROM bdicheq:"informix".sc_param
        WHERE empresa = vEmpresa
        AND codparam = 'FechaIniMovhisOld2';
	
        IF LEN(xFecha) ='8' THEN
            LET vFechaOld2 =  TO_DATE(xFecha, '%m%d%Y');
        ELSE
            LET vFechaOld2 =  TO_DATE(xFecha, '%m/%d/%Y');
        END IF;
        
        -- Descripcion SPEI
        SELECT descripcion
        INTO vDescripcionSpei
        FROM bdinteg:"informix".si_transacc
        WHERE numero = '0331';
        LET vDescripcionSpei = TRIM(vDescripcionSpei);

        -- Consultar repositorio de archivos
        SELECT valor
        INTO vPath
        FROM bdibpi:enet_parametros
        WHERE id_param = 1011;

        -- Comienza procesamiento del JOB
        FOREACH WITH HOLD
            SELECT {+INDEX(bdibei:"informix".bei_consulta_mov status)} status_arch, folio, cuenta,f_inicial,f_final
                    INTO vStatus, vFolio, vCuenta,vFinicial,vFfinal
            FROM "informix".bei_consulta_mov
            WHERE status_arch = '01' OR status_arch = '04'

            -- A) Realizar la consulta de movimientos:
            IF (vStatus = '01') THEN
            --{
                -- Reiniciar cod_ret en caso de error
                LET cod_ret  = '00000';
                -- Actualizar status a (En Proceso)
                UPDATE "informix".bei_consulta_mov
                SET  status_arch='02', fh_status_arch=TO_CHAR(current)
                WHERE folio = vFolio and cuenta=vCuenta;


                -- Movimientos del Dia
                IF (vFinicial = vFechaDia OR vFfinal = vFechaDia) THEN
                --{
                    FOREACH WITH HOLD
                        -- Busca movimientos del dia
                        SELECT movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc, movs.cuenta, movs.fech_hor, 
						(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
							ELSE movs.num_serial 
						END) AS num_serial_nuevo
                        INTO  vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                        FROM bdicheq:"informix".sc_movdia AS movs, bdinteg:"informix".si_transacc AS trans
                        WHERE movs.cuenta = vCuenta
                        AND movs.empresa = vEmpresa
                        AND movs.empresa = trans.empresa
                        AND movs.fech_alt = vFechaDia
                        AND trans.numero = movs.transacc
                        AND movs.cancelad <> "S"
                        AND trans.se_emite_edocta = "S"
						and trans.sistema= '01'
                        ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                        IF vnaturaleza = 'C' THEN
                            LET vmonto_tot =( vmonto_tot * -1);
                        ELSE
                            LET vmonto_tot=vmonto_tot;
                        END IF;

                        IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                            LET vDescripcion=vDescripcionSpei;
                        ELIF   vnumero='0231' THEN
                            LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                        ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                            LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                        ELSE
                            LET vDescripcion=vDescripcion;
                        END IF;

                        ----------------------------------------------------------------------------------------------
                        IF (vnumero = '0273') THEN -- ABONO SPEI
                            SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                            FROM bdispei:"informix".tblpago a, bdinteg:"informix".si_bancos b --del dia
                            WHERE a.vchrclaverastreo = vreferencia
                            AND a.cvecesifbcoord = b.cvecesif
                            AND a.chrsentidopago='R'
                            AND a.cvecesifbcodest='40137'
                            AND a.intcvetipopago <> 0
                            AND a.chrestatusenvio <> 'C'
                            AND a.dtfechavalor = vfech_alt
                            AND a.vchrnombrebenef IS NOT NULL
                            AND a.vchrcuentabenef IS NOT NULL;

                            IF (vvchrnombrecorto is null)THEN
                                LET vvchrnombrecorto ='';
                            END IF;

                            IF (vvchrcuentaord is null)THEN
                                LET vvchrcuentaord ='';
                            END IF;

                            IF (vvchrnombreord is null)THEN
                                LET vvchrnombreord ='';
                            END IF;

                            IF (vvchrconceptopago2 is null)THEN
                                LET vvchrconceptopago2 ='';
                            END IF;

                            LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                        END IF;
                        ----------------------------------------------------------------------------------------------

                        IF (NVL(TRIM(vreferencia),'') = '') THEN
                            LET vnumero=vtransacc;
                        ELIF vnumero='3333' THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                        ELIF vnumero='0231' THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                        ELIF (vnumero='3320' OR vnumero = '3321') THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                        ELSE
                            LET vreferencia=TRIM(vreferencia);
                        END IF;

                        IF vcomienza = -1 THEN
                            BEGIN WORK;
                            LET vcontador = 1;
                            LET vcomienza = 0;
                        END IF;

                        INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                        VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                        IF (vcontador = vregistros) THEN
                            COMMIT WORK;
                            LET vcontador = 0;
                            LET vcomienza = -1;
                        ELSE
                            LET vcontador = vcontador + 1 ;
                        END IF;

                        CONTINUE FOREACH;
                    END FOREACH;
                END IF;
                --}

                -- Historico de Movimientos sc_movhis
                IF (vFinicial >= vFechaHis AND vFinicial < vFechaDia) THEN
                --{
                    FOREACH WITH HOLD
                        SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc,movs.cuenta,movs.fech_hor,
						(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
							ELSE movs.num_serial 
						END) AS num_serial_nuevo
                        INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                        FROM bdicheq:"informix".sc_movhis AS movs, bdinteg:"informix".si_transacc AS trans
                        WHERE trans.empresa = movs.empresa
                        AND trans.numero = movs.transacc
                        AND trans.se_emite_edocta = "S"
                        AND movs.empresa = vEmpresa
                        AND movs.cuenta = vCuenta
                        AND movs.fech_alt >= vFinicial
                        AND movs.fech_alt <= vFfinal
                        AND movs.cancelad <> "S"
						and trans.sistema= '01'
                        ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                        IF vnaturaleza = 'C' THEN
                            LET vmonto_tot =( vmonto_tot * -1);
                        ELSE
                            LET vmonto_tot=vmonto_tot;
                        END IF;

                        IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                            LET vDescripcion=vDescripcionSpei;
                        ELIF   vnumero='0231' THEN
                            LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                        ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                            LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                        ELSE
                            LET vDescripcion=vDescripcion;
                        END IF;
                        ----------------------------------------------------------------------------------------------
                        IF (vnumero = '0273') THEN -- ABONO SPEI
                            SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                    INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                            FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                            WHERE a.vchrclaverastreo = vreferencia
                            AND a.cvecesifbcoord = b.cvecesif
                            AND a.chrsentidopago='R'
                            AND a.cvecesifbcodest='40137'
                            AND a.intcvetipopago <> 0
                            AND a.chrestatusenvio <> 'C'
                            AND a.dtfechavalor = vfech_alt
                            AND a.vchrnombrebenef IS NOT NULL
                            AND a.vchrcuentabenef IS NOT NULL;

                            IF (vvchrnombrecorto is null)THEN
                                LET vvchrnombrecorto ='';
                            END IF;

                            IF (vvchrcuentaord is null)THEN
                                LET vvchrcuentaord ='';
                            END IF;

                            IF (vvchrnombreord is null)THEN
                                LET vvchrnombreord ='';
                            END IF;

                            IF (vvchrconceptopago2 is null)THEN
                                LET vvchrconceptopago2 ='';
                            END IF;

                            LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                        END IF;
                        ----------------------------------------------------------------------------------------------


                        IF (NVL(TRIM(vreferencia),'') = '') THEN
                            LET vnumero=vtransacc;
                        ELIF vnumero='3333' THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                        ELIF vnumero='0231' THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                        ELIF (vnumero='3320' OR vnumero = '3321') THEN
                            LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                        ELSE
                            LET vreferencia=TRIM(vreferencia);
                        END IF;

                        IF vcomienza = -1 THEN
                            BEGIN WORK;
                            LET vcontador = 1;
                            LET vcomienza = 0;
                        END IF;

                        INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                        VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                        IF (vcontador = vregistros) THEN
                            COMMIT WORK;
                            LET vcontador = 0;
                            LET vcomienza = -1;
                        ELSE
                            LET vcontador = vcontador + 1 ;
                        END IF;

                        CONTINUE FOREACH;
                    END FOREACH;
                --}
                ELIF (vFinicial >= vFechaOld AND vFinicial < vFechaHis) THEN
                --{
                    -- En caso de que la fecha final supere el limite del historico (sc_movhis_old)
                    IF (vFfinal >= vFechaHis) THEN
                    --{
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc, movs.cuenta, movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis_old AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE movs.cuenta = vCuenta
                            AND movs.empresa = vEmpresa
                            AND movs.empresa = trans.empresa
                            AND movs.fech_alt >= vFinicial
                            AND movs.fech_alt < vFechaHis
                            AND trans.numero = movs.transacc
                            AND movs.cancelad <> "S"
                            AND trans.se_emite_edocta = "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                    INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------


                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;


                        -- Insertar de acuerdo a registros superiores al limite
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc, movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE movs.cuenta = vCuenta
                            AND movs.empresa = vEmpresa
                            AND movs.empresa = trans.empresa
                            AND movs.fech_alt >= vFechaHis
                            AND movs.fech_alt <= vFfinal
                            AND trans.numero = movs.transacc
                            AND movs.cancelad <> "S"
                            AND trans.se_emite_edocta = "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------


                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                             CONTINUE FOREACH;
                        END FOREACH;

                    --}
                    ELSE
                    --{
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc,movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis_old AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE movs.cuenta = vCuenta
                            AND movs.empresa = vEmpresa
                            AND movs.empresa = trans.empresa
                            AND movs.fech_alt >= vFinicial
                            AND movs.fech_alt <= vFfinal
                            AND trans.numero = movs.transacc
                            AND movs.cancelad <> "S"
                            AND trans.se_emite_edocta = "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------


                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;
                    --}
                    END IF;

                --}
                ----------------------------------------------------------------------------------------------------------------------------
                --  historico sc_movhis_old 2

                ELIF (vFinicial >= vFechaOld2 AND vFinicial < vFechaOld) THEN
                --{
                    -- En caso de que la fecha final supere el limite del historico
                    IF (vFfinal >= vFechaOld) THEN
                    --{
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc, movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis_old2 AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE trans.empresa = movs.empresa
                            AND trans.numero = movs.transacc
                            AND trans.se_emite_edocta = "S"
                            AND movs.empresa = vEmpresa
                            AND movs.cuenta = vCuenta
                            AND movs.fech_alt >= vFinicial
                            AND movs.fech_alt <= vFfinal
                            AND movs.cancelad <> "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------



                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;


                        -- Insertar de acuerdo a registros superiores al limite
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc,movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis_old AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE movs.cuenta = vCuenta
                            AND movs.empresa = vEmpresa
                            AND movs.empresa = trans.empresa
                            AND movs.fech_alt >= vFechaOld
                            AND movs.fech_alt <= vFfinal
                            AND trans.numero = movs.transacc
                            AND movs.cancelad <> "S"
                            AND trans.se_emite_edocta = "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------


                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;


                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc,movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE movs.cuenta = vCuenta
                            AND movs.empresa = vEmpresa
                            AND movs.empresa = trans.empresa
                            AND movs.fech_alt >= vFechaHis
                            AND movs.fech_alt <= vFfinal
                            AND trans.numero = movs.transacc
                            AND movs.cancelad <> "S"
                            AND trans.se_emite_edocta = "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                AND a.cvecesifbcoord = b.cvecesif
                                AND a.chrsentidopago='R'
                                AND a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------



                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;
                    --}
                    ELSE
                    --{
                        FOREACH WITH HOLD
                            SELECT   movs.fech_alt,trans.numero,trans.naturaleza,movs.sdo_cuenta,movs.monto_tot,trans.descripcion,movs.referencia,movs.transacc_suc, movs.transacc,movs.cuenta,movs.fech_hor,
							(CASE WHEN char_length(to_char(movs.num_serial)) <= 8 THEN movs.num_serial + 2147483647 
								ELSE movs.num_serial 
							END) AS num_serial_nuevo
                            INTO vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vtransacc_suc,vtransacc,vnumcuenta,vfech_hor,vnum_serial
                            FROM bdicheq:"informix".sc_movhis_old2 AS movs, bdinteg:"informix".si_transacc AS trans
                            WHERE trans.empresa = movs.empresa
                            AND trans.numero = movs.transacc
                            AND trans.se_emite_edocta = "S"
                            AND movs.empresa = vEmpresa
                            AND movs.cuenta = vCuenta
                            AND movs.fech_alt >= vFinicial
                            AND movs.fech_alt <= vFfinal
                            AND movs.cancelad <> "S"
							and trans.sistema= '01'
                            ORDER BY movs.fech_alt DESC, num_serial_nuevo DESC

                            IF vnaturaleza = 'C' THEN
                                LET vmonto_tot =( vmonto_tot * -1);
                            ELSE
                                LET vmonto_tot=vmonto_tot;
                            END IF;

                            IF (vnumero = '0274' AND vtransacc_suc = '0331') THEN
                                LET vDescripcion=vDescripcionSpei;
                            ELIF   vnumero='0231' THEN
                                LET vDescripcion= TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 1 FOR 10));
                            ELIF   (vnumero = '3320' OR vnumero = '3321') THEN
                                LET vDescripcion=  TRIM(vDescripcion) || " " || TRIM(SUBSTRING(vreferencia FROM 23 FOR 36));
                            ELSE
                                LET vDescripcion=vDescripcion;
                            END IF;

                            ----------------------------------------------------------------------------------------------
                            IF (vnumero = '0273') THEN -- ABONO SPEI
                                SELECT b.vchrnombrecorto, a.vchrcuentaord, a.vchrnombreord, a.vchrconceptopago2
                                        INTO vvchrnombrecorto, vvchrcuentaord, vvchrnombreord, vvchrconceptopago2
                                FROM bdispei:"informix".tblhistpago a, bdinteg:"informix".si_bancos b --de ayer para atras
                                WHERE a.vchrclaverastreo = vreferencia
                                and a.cvecesifbcoord = b.cvecesif
                                and a.chrsentidopago='R'
                                and a.cvecesifbcodest='40137'
                                AND a.intcvetipopago <> 0
                                AND a.chrestatusenvio <> 'C'
                                AND a.dtfechavalor = vfech_alt
                                AND a.vchrnombrebenef IS NOT NULL
                                AND a.vchrcuentabenef IS NOT NULL;

                                IF (vvchrnombrecorto is null)THEN
                                    LET vvchrnombrecorto ='';
                                END IF;

                                IF (vvchrcuentaord is null)THEN
                                    LET vvchrcuentaord ='';
                                END IF;

                                IF (vvchrnombreord is null)THEN
                                    LET vvchrnombreord ='';
                                END IF;

                                IF (vvchrconceptopago2 is null)THEN
                                    LET vvchrconceptopago2 ='';
                                END IF;


                                LET vreferencia=  TRIM(vreferencia) || " " || TRIM(vvchrnombrecorto) || " " || TRIM(vvchrcuentaord)|| " " ||TRIM (vvchrnombreord) || " " || TRIM (vvchrconceptopago2);

                            END IF;
                            ----------------------------------------------------------------------------------------------


                            IF (NVL(TRIM(vreferencia),'') = '') THEN
                                LET vnumero=vtransacc;
                            ELIF vnumero='3333' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 9 FOR 16));
                            ELIF vnumero='0231' THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 12));
                            ELIF (vnumero='3320' OR vnumero = '3321') THEN
                                LET vreferencia= TRIM(SUBSTRING(vreferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(vreferencia FROM 7 FOR 20));
                            ELSE
                                LET vreferencia=TRIM(vreferencia);
                            END IF;

                            IF vcomienza = -1 THEN
                                BEGIN WORK;
                                LET vcontador = 1;
                                LET vcomienza = 0;
                            END IF;

                            INSERT INTO "informix".bei_movimientos_cons(folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta,fecha_hor,num_serial)
                            VALUES(vFolio,vfech_alt,vnumero,vnaturaleza,vsdo_cuenta, vmonto_tot,vDescripcion,vreferencia,vnumcuenta,vfech_hor,vnum_serial);

                            IF (vcontador = vregistros) THEN
                                COMMIT WORK;
                                LET vcontador = 0;
                                LET vcomienza = -1;
                            ELSE
                                LET vcontador = vcontador + 1 ;
                            END IF;
                            CONTINUE FOREACH;
                        END FOREACH;

                    END IF;
                    --}
                END IF;
                --}



                IF (vcontador > 1) THEN
                    COMMIT WORK;
                    LET vcontador = 0;
                    LET vcomienza = -1;
                END IF;


                -- Obtener total de registros
                SELECT COUNT(*) AS total_registros INTO vTotalReg FROM "informix".bei_movimientos_cons WHERE folio = vFolio;

                -- Actualizar estatus a (Resuelto)
                UPDATE "informix".bei_consulta_mov
                SET (status_arch,fh_status_arch,total_registros) = ('03', TO_CHAR(current),vTotalReg)
                WHERE folio = vFolio;




                -- B) Generar archivo con movimientos:
                -- Actualizar estatus a (Resuelto)
                UPDATE "informix".bei_consulta_mov
                SET (status_arch,fh_status_arch,nombre) = ('04',  TO_CHAR(current), TRIM(vFolio)||'.txt')
                WHERE folio = vFolio;

                -- Generar el archivo
                EXECUTE PROCEDURE "informix".trace_movimientos_cons(vFolio, vPath) INTO cod_ret;


                IF (cod_ret == '00005') THEN
                    -- Problemas con la informacion para generar el archivo
                    UPDATE "informix".bei_consulta_mov
                    SET (status_arch,fh_status_arch) = ('05', TO_CHAR(current))
                    WHERE folio = vFolio;
                ELIF (cod_ret != '00005' AND cod_ret != '00000') THEN
                    -- Problemas con la informacion para generar el archivo
                    UPDATE "informix".bei_consulta_mov
                    SET (status_arch,fh_status_arch) = ('06', TO_CHAR(current))
                    WHERE folio = vFolio;
                END IF;

				--INC 03 501
                -- Depurar todos los movimientos que se insertaron para generar el archivo txt de movimientos
                EXECUTE PROCEDURE "informix".sp_depura_arch_movimientos(vFolio) INTO vChrCodRetDepuracion;

            --}
            ELIF (vStatus == '04') THEN
            --{
                -- C) Depurar los registros con mas de 7 dias
                --SELECT (TODAY - TO_DATE(f_solicitud_arch, '%d/%m/%Y'))::INTERVAL DAY(4) TO DAY::CHAR(5)::INTEGER INTO vDiferencia
                SELECT (TODAY - TO_DATE(f_solicitud_arch, '%d/%m/%Y'))::INTERVAL DAY(2) TO DAY::CHAR(5)::INTEGER INTO vDiferencia
                FROM "informix".bei_consulta_mov
                WHERE folio = vFolio and status_arch = '04';

                --##### quitar
                -- LET vDiferencia = 3;

                -- Diferencia de 7 dias en base al calculo del query de arriba
                IF (vDiferencia >= 7) THEN
                    -- Actualizar estatus a (Cerrado)
                    UPDATE "informix".bei_consulta_mov
                    SET (status_arch,fh_status_arch) = ('07', TO_CHAR(current))
                    WHERE folio = vFolio;
                    -- Eliminar movimientos del folio solicitante
                    SYSTEM 'rm -r '||TRIM(vPath)||TRIM(vFolio)||'.txt';
                END IF;
            END IF;
            --}
        END FOREACH;

        UPDATE bdibei:bei_consulta_mov set status_arch = '06'
        WHERE folio IN (SELECT  folio  FROM bdibei:bei_consulta_mov
        WHERE TO_DATE(fh_status_arch) <  (EXTEND(CURRENT YEAR TO day) - INTERVAL(7) day TO day)
                AND status_arch IN ('02','04','05'));

        DELETE  FROM bdibei:bei_consulta_mov
        WHERE status_arch = '06';

    END;
    RETURN cod_ret;

END PROCEDURE;