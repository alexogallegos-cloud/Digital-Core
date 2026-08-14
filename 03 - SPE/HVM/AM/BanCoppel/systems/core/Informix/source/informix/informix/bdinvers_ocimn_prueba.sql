CREATE PROCEDURE "informix".ocimn_prueba(pFecha DATE)
--DATOS A REGRESAR
RETURNING
    CHAR(6),
    CHAR(3),
    CHAR(1),
    INTEGER,
    DATE,
    CHAR(1),
    CHAR(4),
    DATE,
    DATE,
    DECIMAL (9,4),
    CHAR (1),
    DECIMAL (9,4),
    CHAR(3),
    CHAR(3),
    CHAR(3),
    CHAR(1),
    CHAR(1),
    CHAR(1),
    CHAR(2),
    CHAR(2),
    CHAR(1),
    CHAR(8),
    CHAR(20),
    SMALLINT,
    CHAR(1),
    CHAR(4);

--DEFINICION DE VARIABLES
    DEFINE  vInstitucion            CHAR(6);
    DEFINE  vOperacion            CHAR(3);
    DEFINE  vOficina                   CHAR(1);
    DEFINE  vImporte                  INTEGER;
    DEFINE  vFechaIni                 DATE;
    DEFINE  vFamort                    CHAR(1);
    DEFINE  vNoAmort                 CHAR(4);
    DEFINE  vFechaVcto              DATE;
    DEFINE  vFechaVctoAnt        DATE;
    DEFINE  vTasa                       DECIMAL (9,4);
    DEFINE  vForDetTasa           CHAR(1);
    DEFINE  vTasaDetTasa       DECIMAL (9, 4);
    DEFINE  vPunTasa               CHAR(3);
    DEFINE  vFacTasa                CHAR(3);
    DEFINE  vRevTasa                CHAR(3);
    DEFINE  vResParte               CHAR(1);
    DEFINE vTipoParte                CHAR(1);
    DEFINE  vParteOper              CHAR(1);
    DEFINE  vMoneda                  CHAR(2);
    DEFINE  vOriRecur                CHAR(2);
    DEFINE  vAreaNeg                CHAR(1);
    DEFINE  vLocalBanx             CHAR(8);
    DEFINE  vNoCliente              CHAR(20);
    DEFINE  vSecuencia              INTEGER;
    DEFINE  vIdentAmor              CHAR(1);
    DEFINE  vModifica                  CHAR(4);
    DEFINE vSqlErr                      SMALLINT;
    DEFINE vCiudad                     CHAR(3);
    DEFINE vEstado                      CHAR(2);
    DEFINE vsql                             CHAR(500);
    DEFINE v_directorio              CHAR(30);


--INICIALIZACION DE VARIABLES

    LET vInstitucion = "040137";
    LET vOperacion = "130";
    LET vOficina = "R";
    LET vImporte = 0;
    LET vFechaIni = "";
    LET vFamort = "U";
    LET vNoAmort = "";
    LET vFechaVcto = "";
    LET vFechaVctoAnt = "";
    LET vTasa = 0;
    LET vForDetTasa = "F";
    LET vTasaDetTasa = NULL;
    LET vPunTasa = "";
    LET vFacTasa = "";
    LET vRevTasa = "";
    LET  vResParte = "M";
    LET vTipoParte = "F";
    LET  vParteOper = "";
    LET  vMoneda = "";
    LET  vOriRecur = "";
    LET  vAreaNeg = "V";
    LET  vLocalBanx = "";
    LET  vNoCliente = "";
    LET  vSecuencia = 0;
    LET  vIdentAmor = "1";
    LET  vModifica = "";
    LET vSqlErr = 0;
    LET vCiudad = "";
    LET vEstado = "";
    LET vsql = "";
    LET v_directorio  = "";

BEGIN

            ON EXCEPTION SET vSqlErr
                    IF vSqlErr <> 0 THEN
                        LET  vInstitucion = vSqlErr;
                        RETURN  vInstitucion, vOperacion, vOficina,  vImporte, vFechaIni, vFamort, vNoAmort, vFechaVcto, vFechaVctoAnt,
                                         vTasa, vForDetTasa, vTasaDetTasa, vPunTasa, vFacTasa, vRevTasa, vResParte, vTipoParte, vParteOper, vMoneda,
                                         vOriRecur, vAreaNeg,  vLocalBanx,  vNoCliente,  vSecuencia, vIdentAmor, vModifica;
                    END IF
            end exception ;
                    SET DEBUG FILE TO "/tmp/ocimn.out";   -- "/pisa/pisabanco/pisa_ftes/inversiones/ocimn.out";
                    TRACE ON;

IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sv_ocimn' ) THEN
    DROP TABLE sv_ocimn;
END IF;

CREATE TABLE bdinvers:sv_ocimn (institucion CHAR(6),  Operacion CHAR(3), Oficina CHAR(1), Importe  INTEGER, FechaIni DATE,
                                                                Famort CHAR(1), NoAmort CHAR(4),  FechaVcto DATE, FechaVctoAnt DATE, Tasa DECIMAL (9,4),
                                                                ForDetTasa  CHAR(1),  TasaDetTasa   DECIMAL (9, 4), PunTasa  CHAR(3), FacTasa  CHAR(3), RevTasa  CHAR(3),
                                                                ResParte  CHAR(1), TipoParte  CHAR(1), ParteOper CHAR(1),  Moneda  CHAR(2), OriRecur CHAR(2),
                                                                AreaNeg  CHAR(1),  LocalBanx CHAR(8), NoCliente  CHAR(20), Secuencia  INTEGER, IdentAmor CHAR(1),
                                                                Modifica CHAR(4) );

FOREACH
                SELECT   inv.fecha_alta, round(inv.capital/1000), inv.fecha_venc, inv.tasa, inv.num_cte, ins.moneda, suc.ciudad, suc.estado
                 INTO  vFechaIni, vImporte, vFechaVcto, vTasa, vNoCliente, vMoneda, vCiudad,  vEstado
                FROM sv_fechas fec, sv_maeinv inv
                INNER JOIN bdinvers:sv_instrum ins  ON  ins.cod_instrum = inv.cod_instrum
                INNER JOIN bdinteg: si_sucursales suc ON suc.sucursal = inv.sucursal
                WHERE inv.fecha_alta = pFecha and inv.status_cta = "1"
              --GROUP BY inv.fecha_alta, inv.capital, inv.fecha_venc, inv.tasa, inv.num_cte,  ins.moneda, suc.ciudad, suc.estado
                ORDER BY inv.num_cte

                SELECT localidad_banxico INTO vLocalBanx  FROM bdinteg:si_ciudades WHERE ciudad = vCiudad AND estado = vEstado;

                IF vFechaIni = "" OR vImporte = 0 THEN
                        LET vInstitucion = "999999";  --DATOS INSUFICIENTES
                END IF;
                LET vSecuencia = vSecuencia + 1;

               --IF vSecuencia = 1 THEN
                  --  SELECT limit 1  vInstitucion AS institucion, vOperacion AS operacion, vOficina AS oficina,  vImporte AS importe, vFechaIni AS FechaIni,
                     --               vFamort AS Famort, vNoAmort AS NoAmort, vFechaVcto AS FechaVcto, vFechaVctoAnt AS FechaVctoAnt, vTasa AS Tasa,
                        --            vForDetTasa AS ForDetTasa, vTasaDetTasa AS TasaDetTasa, vPunTasa AS PunTasa, vFacTasa AS FacTasa,  vRevTasa AS  RevTasa,
                           --         vResParte AS ResParte, vTipoParte AS TipoParte, vParteOper AS ParteOper, vMoneda AS Moneda,
                              --      vOriRecur AS OriRecur, vAreaNeg AS AreaNeg,  vLocalBanx AS LocalBanx,  vNoCliente AS NoCliente,  vSecuencia AS Secuencia,
                                 --   vIdentAmor AS IdentAmor, vModifica AS Modifica
                    -- FROM dual
                     --INTO temp  sv_ocimn;
               --ELSE

                     INSERT INTO sv_ocimn VALUES (vInstitucion, vOperacion, vOficina,  vImporte, vFechaIni, vFamort, vNoAmort, vFechaVcto, vFechaVctoAnt,
                                  vTasa, vForDetTasa, vTasaDetTasa, vPunTasa, vFacTasa, vRevTasa, vResParte, vTipoParte, vParteOper, vMoneda,
                                  vOriRecur, vAreaNeg,  vLocalBanx,  vNoCliente,  vSecuencia, vIdentAmor, vModifica);
              -- END IF;


                 RETURN  vInstitucion, vOperacion, vOficina,  vImporte, vFechaIni, vFamort, vNoAmort, vFechaVcto, vFechaVctoAnt,
                                  vTasa, vForDetTasa, vTasaDetTasa, vPunTasa, vFacTasa, vRevTasa, vResParte, vTipoParte, vParteOper, vMoneda,
                                  vOriRecur, vAreaNeg,  vLocalBanx,  vNoCliente,  vSecuencia, vIdentAmor, vModifica WITH RESUME;

END FOREACH;

    LET v_directorio   =  "/tmp/ocimn.txt";  --"/pisa/pisabanco/pisa_ftes/inversion/ocimn.txt";
     let vsql = '';

    LET  vsql = 'echo "UNLOAD TO '   || (v_directorio) ||
  ' SELECT institucion, Operacion, Oficina, Importe,  to_char(FechaIni, ''' || '%Y/%m/%d' || ''' ), Famort, NoAmort,  to_char(FechaVcto,''' || '%Y/%m/%d' || ''' ),   to_char(FechaVctoAnt, ''' || '%Y/%m/%d' || ''' ), Tasa::char(14), ForDetTasa, TasaDetTasa::char(14), PunTasa, FacTasa, RevTasa, ResParte, TipoParte, ParteOper, Moneda, OriRecur, AreaNeg, LocalBanx, NoCliente, Secuencia, IdentAmor, Modifica   FROM bdinvers:sv_ocimn" > /tmp/query.sql';
  --' SELECT * FROM bdinvers:sv_ocimn" > /tmp/query.sql';
      SYSTEM vsql;
     let vsql = '';
      LET vsql = "dbaccess bdinvers /tmp/query.sql ";

     SYSTEM vsql;
     DROP TABLE bdinvers:sv_ocimn;
END;
END PROCEDURE;