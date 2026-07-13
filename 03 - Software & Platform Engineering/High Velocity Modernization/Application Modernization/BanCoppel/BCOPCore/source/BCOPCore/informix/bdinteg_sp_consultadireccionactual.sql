CREATE PROCEDURE "informix".sp_consultadireccionactual(pConsulta INTEGER, pEmpresa CHAR(3), pNumcte CHAR(20), pSecuencia INTEGER, pTipoDir CHAR(1) )
     RETURNING CHAR(5), INTEGER, CHAR(1), CHAR(30), CHAR(60), CHAR(30), CHAR(32), CHAR(30), CHAR(10), CHAR(10), CHAR(6), CHAR(5), CHAR(1),
                          CHAR(13), CHAR(13), CHAR(13), CHAR(5), CHAR(5), CHAR(5), CHAR(5), CHAR(5), CHAR(5), CHAR(5);

-- Creado: Daniela Ramirez Perez
-- Fecha: 25/03/2011
-- Actividad: Consulta direccion actual del cliente

-- Modificado: Jessica Gutiérrez
-- Fecha: 17/05/2014
-- Descripción: Se modifican las consultas para mostrar todas las direcciones del cliente, ordenadas en forma descendente.
--              Mostrando la direccion mas actual en primer lugar y asi sucesivamente.

-- Se definen variables
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;

        DEFINE iRegistroActual INTEGER;
        DEFINE iRegistroDir INTEGER;
        DEFINE cTipo_dir CHAR(1);
        DEFINE cEstado CHAR(30);
        DEFINE cCiudad CHAR(60);
        DEFINE cMunicipio CHAR(30);
        DEFINE cNombreZona CHAR(32);
        DEFINE cNombreCalle CHAR(30);
        DEFINE cNumExtCalle CHAR(10);
        DEFINE cNumIntCalle CHAR(10);
        DEFINE cDepto CHAR(6);
        DEFINE cCod_postal CHAR(5);
        DEFINE cPuntoCardinal CHAR(1);
        DEFINE cTelefono1 CHAR(13);
        DEFINE cTelefono2 CHAR(13);
        DEFINE cTelefono3 CHAR(13);
        DEFINE cExtension CHAR(5);
        DEFINE iManzana CHAR(5);
        DEFINE iOtros CHAR(5);
        DEFINE iAndador CHAR(5);
        DEFINE iEtapa CHAR(5);
        DEFINE iEdificio CHAR(5);
        DEFINE iEntrada CHAR(5);
        DEFINE cEmpresa CHAR(3);
        DEFINE cNumCte CHAR(20);

-- Se inicializan variables
        LET cCodRet = "00000";
        LET iSqlErr = 0;

        LET iRegistroActual = 0;
        LET iRegistroDir = 0;
        LET cTipo_dir = " ";
        LET cEstado = " ";
        LET cCiudad = " ";
        LET cMunicipio = " ";
        LET cNombreZona = " ";
        LET cNombreCalle = " ";
        LET cNumExtCalle = " ";
        LET cNumIntCalle = " ";
        LET cDepto = " ";
        LET cCod_postal = " ";
        LET cPuntoCardinal = " ";
        LET cTelefono1 = " ";
        LET cTelefono2 = " ";
        LET cTelefono3 = " ";
        LET cExtension = " ";
        LET iManzana = " ";
        LET iOtros = " ";
        LET iAndador = " ";
        LET iEtapa = " ";
        LET iEdificio = " ";
        LET iEntrada = " ";
        LET cEmpresa = " ";
        LET cNumCte = " ";

--        SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consultadireccionactual.out";
--        TRACE ON;

        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr !=0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, iRegistroActual, cTipo_dir, cEstado, cCiudad, cMunicipio, cNombreZona, cNombreCalle, cNumExtCalle, cNumIntCalle, cDepto, cCod_postal,
                                              cPuntoCardinal, cTelefono1, cTelefono2, cTelefono3, cExtension, iManzana, iOtros, iAndador, iEtapa, iEdificio, iEntrada;
                        END IF;
                END EXCEPTION;

                IF pConsulta = 1 THEN --Regresa el número de registros

                        SELECT COUNT(distinct dir.secuencia)
						INTO iRegistroActual
						FROM bdinteg:"informix".si_cliente AS cte
						LEFT JOIN bdinteg:"informix".si_direcciones_actual dir ON (dir.numcte=cte.numcte)
						WHERE cte.empresa = pEmpresa AND cte.numcte = pNumcte;
						
                                RETURN  cCodRet, iRegistroActual, cTipo_dir, cEstado, cCiudad, cMunicipio, cNombreZona, cNombreCalle, cNumExtCalle, cNumIntCalle, cDepto, cCod_postal,
                                                  cPuntoCardinal, cTelefono1, cTelefono2, cTelefono3, cExtension, iManzana, iOtros, iAndador, iEtapa, iEdificio, iEntrada;

              ELIF pConsulta = 2 THEN --Regresa secuencia con tipo de direccion

                    SELECT  {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} empresa, numcte
                    INTO cEmpresa, cNumCte
                    FROM bdinteg:"informix".si_cliente
                    WHERE empresa = pEmpresa AND numcte = pNumcte;

                         FOREACH

                                    SELECT {+INDEX (bdinteg:si_direcciones_actual idx_diract_ctetpo)} dir.secuencia, dir.tipo_dir
									INTO iRegistroActual, cTipo_dir
									FROM bdinteg:si_direcciones_actual AS dir
									WHERE dir.numcte = cNumCte --AND (dir.tipo_dir = 1 OR dir.tipo_dir = 2)
									order by secuencia desc

                                    RETURN  cCodRet, iRegistroActual, cTipo_dir, cEstado, cCiudad, cMunicipio, cNombreZona, cNombreCalle, cNumExtCalle, cNumIntCalle, cDepto, cCod_postal,
                                                     cPuntoCardinal, cTelefono1, cTelefono2, cTelefono3, cExtension, iManzana, iOtros, iAndador, iEtapa, iEdificio, iEntrada WITH RESUME;

                         END FOREACH;

              ELIF pConsulta = 3 THEN --Regresa direccion

                    SELECT  {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} empresa, numcte
                    INTO cEmpresa, cNumCte
                    FROM bdinteg:"informix".si_cliente
                    WHERE empresa = pEmpresa AND numcte = pNumcte;

                            SELECT  {+INDEX (bdinteg:si_direcciones inx_direcciones)}
                                          dir.secuencia, dir.tipo_dir, edo.nombre AS estado, ciu.nombre AS ciudad, mun.nombre AS municipio, zon.nombrezona, cal.nombrecalle,
                                          dir.numeroextcalle, dir.numerointcalle, dir.departamento, dir.cod_postal, dir.puntocardinal,
                                          dir.manzana, dir.otros, dir.andador, dir.etapa, dir.edificio, dir.entrada
                            INTO iRegistroActual, cTipo_dir, cEstado, cCiudad, cMunicipio, cNombreZona, cNombreCalle, cNumExtCalle, cNumIntCalle, cDepto, cCod_postal,
                                     cPuntoCardinal, iManzana, iOtros, iAndador, iEtapa, iEdificio, iEntrada
                            FROM bdinteg:si_direcciones AS dir
                            LEFT JOIN si_estados AS edo ON (edo.estado = dir.estado)
                            LEFT JOIN si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = '001')
                            LEFT JOIN si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
                            LEFT JOIN si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
                            LEFT JOIN si_municipios AS mun ON (mun.municipio = dir.municipio AND mun.pais = '001' AND mun.ciudad = dir.ciudad AND mun.estado = dir.estado)
                            WHERE dir.numcte = cNumCte AND dir.secuencia = pSecuencia;

					
                    --CONSULTA LOS NUEVOS TELEFONOS
                    LET cTelefono1 = '';
                    LET cTelefono2 = '';
                    LET cTelefono3 = '';
                    LET cExtension = '';

                    SELECT telefono INTO cTelefono1 ---TELEFONO PARTICULAR
                    from si_telefonos_actual
                    where numcte = pNumcte and tipo_tel = 1;

                    SELECT telefono,extension INTO cTelefono2,cExtension  ---TELEFONO TRABAJO
                    from si_telefonos_actual
                    where numcte = pNumcte and tipo_tel = 2;

                    SELECT telefono  INTO cTelefono3 ---TELEFONO CELULAR
                    from si_telefonos_actual
                    where numcte = pNumcte and tipo_tel = 3;

                            RETURN  cCodRet, iRegistroActual, cTipo_dir, cEstado, cCiudad, cMunicipio, cNombreZona, cNombreCalle, cNumExtCalle, cNumIntCalle, cDepto, cCod_postal,
                                             cPuntoCardinal, cTelefono1, cTelefono2, cTelefono3, cExtension, iManzana, iOtros, iAndador, iEtapa, iEdificio, iEntrada;
            END IF;

       END;

END PROCEDURE;