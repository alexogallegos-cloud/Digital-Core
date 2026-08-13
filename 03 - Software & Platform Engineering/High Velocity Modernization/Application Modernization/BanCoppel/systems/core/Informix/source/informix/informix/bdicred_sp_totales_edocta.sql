create procedure "informix".sp_totales_edocta (pFecha date, pCentro char(6), pSucursal char(30))
    returning
    char (6),
    char (4),
    char (20),
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    char(30),
    char(4);

    define cCentro char(6);
    define cNumCiudad char(4);
    define cNomCiudad Char (20);
    define iCantidad integer;
    define icobadministrativa integer;
    define icobextrajudicial integer;
    define irutaincompleta integer;
    define iunahoja integer;
    define idoshojas integer;
    define itreshojas integer;
    define icuatrohojas integer;
    define icincoomashojas integer;
    define csucursal_nombre char(30);
    define iSucursal char(4);

    define iLineasHuno integer;
    define iLineasHDos integer;
    define iNum_Credito char(20);
    define iLineas integer;
    define iMovs integer; 
    define iPaginas integer;
    
    begin

        set isolation to dirty read;

        If pFecha = '01-01-1900' then
            let pFecha = null;
        End if;
        If pCentro = '' then
            let pCentro = null;
        End if;
        If pSucursal = '' then
            let pSucursal = null;
        End if;
        let iLineasHuno = 62;
        let iLineasHDos = 90;

        select sucursal_nombre, fecha_emision, num_credito, numcte, substr(ruta,1,4)
        as numerociudad, substr(ruta,6,6) as centronomina,
        CASE WHEN cl_cobra IS NOT NULL THEN
            CASE WHEN substr(cl_cobra, bdisolic:fn_obtenposicion(cl_cobra, '/', 15)+1, 1) = "0" THEN
                '0'
            ELSE
            CASE WHEN substr(cl_cobra, bdisolic:fn_obtenposicion(cl_cobra, '/', 15)+1, 1) = "1" THEN
                '1'
            ELSE
                    CASE WHEN substr(cl_cobra, bdisolic:fn_obtenposicion(cl_cobra, '/', 15)+1, 1) = "2" THEN
                        '1'
                    ELSE
                        CASE WHEN substr(cl_cobra, 0, 2) = "02" THEN
                            '1'
                        ELSE
                            CASE WHEN substr(cl_cobra, 0, 2) = "03" THEN
                        '2'
                            ELSE
                                CASE WHEN substr(cl_cobra, 0, 2) = "04" THEN
                            '2'
                    ELSE
                                    CASE WHEN substr(cl_cobra, 0, 2) = "05" THEN
                                '2'
                                    ELSE
                                '0'
                                    END
                    END
                            END
                END
                    END
                END
            END
        ELSE
            '0'
        END as pagosvencidos,
        case when ruta IS NOT NULL THEN
            Case when length(ruta) < 47 then
                '1'
            else
            case when trim(substr(ruta,1, 4)) = "" then
                '1'
            else
                case when Trim(substr(ruta,6, 6)) = "" then
                    '1'
                else
                    case when trim(substr(ruta,13, 8)) = "" then
                        '1'
                    else
                        case when trim(substr (ruta,22, 8)) = "" then
                            '1'
                        else
                            case when trim(substr (ruta,31, 4)) = "" then
                                '1'
                            else
                                case when trim(substr(ruta,36, 6)) = "" then
                                    '1'
                                else
                                    case when trim(substr(ruta,43, 5)) = "" then
                                        '1'
                                    ELSE
                                        '0'
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        else
        '1'
        end as rutaincompleta, 0 as lineas, 0 as movimientos, 1 as paginas
        from  sd_encabezado_edocta
        where fecha_emision = nvl(pfecha, fecha_emision)
        and substr(ruta,6,6) = nvl(pCentro, substr(ruta,6,6))
        and sucursal_nombre = nvl(pSucursal,  sucursal_nombre)
        and num_credito not in (select num_credito from sd_valedocta
        where fecha_proc = nvl(pfecha, fecha_proc))
        into temp tmp_detenc;
  
        ForEach
            Select a.num_credito, count(*) as lineas, --count(distinct secuencia) as movimientos,
                   max(secuencia) as movim,
                case when count(*) - iLineasHuno > 0 then
                   (
                    case when mod (count(*) - iLineasHuno, iLineasHDos) > 0 then
                        ((count(*) - iLineasHuno ) / iLineasHDos ) + 1
                    else
                         (count(*) - iLineasHuno ) / iLineasHDos
                    end
                   ) + 1  --sumar la pag de la caratula
                else
                    1
                end::integer  as paginasedocta
            Into iNum_Credito, iLineas, iMovs, 
                 iPaginas
            From sd_detalle_edocta a
            Where a.fecha_emision = pFecha
            Group by a.fecha_emision, a.num_credito

                Update tmp_detenc
                Set lineas      = iLineas,
                    movimientos = iMovs,
                    paginas     = iPaginas
                Where num_credito   = iNum_Credito
                  and fecha_emision = pFecha;

        End ForEach;

        select a.sucursal_nombre, a.num_credito, a.numerociudad, b.nombreciudad, a.centronomina, a.pagosvencidos, 
               a.rutaincompleta, a.lineas, a.movimientos, a.paginas
        from   tmp_detenc a, bdinteg:si_catciudades b
        where  a.numerociudad = b.numerociudad
        into   temp tmp_detedocta_a;

        select a.sucursal_nombre, a.num_credito, a.numerociudad, a.nombreciudad, b.sucursal, a.centronomina, a.pagosvencidos, 
               a.rutaincompleta, a.lineas, a.movimientos, a.paginas
        from   tmp_detedocta_a a, bdinteg:si_sucursales b
        where  a.sucursal_nombre = b.nombre
        into   temp tmp_detedocta;

        ForEach 
            select centronomina as centro_nomina, numerociudad  as numero_ciudad,
            nombreciudad as nombre_ciudad, count(*) as cantidad_edocta,
            sum (case when (pagosvencidos = 1 ) then 1 else 0 end) as cobadministrativa,
            sum (case when (pagosvencidos = 2 ) then 1 else 0 end) as cobextrajudicial,
            sum (case when (rutaincompleta = 1 ) then 1 else 0 end) as rutaincompleta,
            sum (case when paginas = 1 then 1 else 0 end) as una_hoja,
            sum (case when paginas = 2 then 1 else 0 end) as dos_hojas,
            sum (case when paginas = 3 then 1 else 0 end) as tres_hojas,
            sum (case when paginas = 4 then 1 else 0 end) as cuatro_hojas,
            sum (case when paginas > 4 then 1 else 0 end) as Mas_de_cinco_hojas,
            sucursal_nombre, sucursal
            into cCentro, cNumCiudad, cNomCiudad, iCantidad, icobadministrativa, icobextrajudicial, 
                 irutaincompleta, iunahoja, idoshojas , itreshojas, icuatrohojas, icincoomashojas, csucursal_nombre, iSucursal
            from tmp_detedocta
            group by centronomina, numerociudad, nombreciudad, sucursal_nombre, sucursal
            order by centronomina, numerociudad

            return cCentro, cNumCiudad, cNomCiudad, iCantidad, icobadministrativa, icobextrajudicial, 
                   irutaincompleta, iunahoja, idoshojas , itreshojas, icuatrohojas, icincoomashojas, csucursal_nombre, iSucursal with resume;
        end ForEach;

        if exists(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmp_detenc' ) then
            drop table tmp_detenc;
        end if;

        if exists(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmp_detedocta' ) then
            drop table tmp_detedocta_a;
        end if;

        if exists(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmp_detedocta' ) then
            drop table tmp_detedocta;
        end if;
    end;
    end procedure;