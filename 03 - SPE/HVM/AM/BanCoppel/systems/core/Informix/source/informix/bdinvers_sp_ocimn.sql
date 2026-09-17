CREATE PROCEDURE "informix".sp_ocimn()
--DATOS A REGRESAR
RETURNING
    CHAR(6);    

--DEFINICION DE VARIABLES    
    DEFINE vSqlErr             SMALLINT;    
    DEFINE vsql                CHAR(500);
    DEFINE v_directorio        CHAR(30);

--INICIALIZACION DE VARIABLES    
    LET vSqlErr = 0;    
    LET vsql = "";
    LET v_directorio  = "";

BEGIN

    On Exception Set vSqlErr
        If vSqlErr <> 0 Then            
            RETURN  vSqlErr;
        End If
    End Exception;

    --SET DEBUG FILE TO "/tmp/ocimn.out";   
    --TRACE ON;

    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sv_ocimn' ) THEN
        DROP TABLE sv_ocimn;
    END IF;

    CREATE TABLE bdinvers:sv_ocimn (institucion   CHAR(6),  
                                    Operacion     CHAR(3), 
                                    Oficina       CHAR(1), 
                                    Importe       DECIMAL(10,1), 
                                    FechaIni      DATE,
                                    Famort        CHAR(1), 
                                    NoAmort       CHAR(4),  
                                    FechaVcto     DATE, 
                                    FechaVctoAnt  DATE, 
                                    Tasa          DECIMAL (9,4),                                    
                                    ForDetTasa    CHAR(1),  
                                    TasaDetTasa   DECIMAL (9, 4), 
                                    PunTasa       CHAR(3), 
                                    FacTasa       CHAR(3), 
                                    RevTasa       CHAR(3),                                    
                                    ResParte      CHAR(1), 
                                    TipoParte     CHAR(1), 
                                    ParteOper     CHAR(1),  
                                    Moneda        CHAR(2), 
                                    OriRecur      CHAR(2),                                    
                                    AreaNeg       CHAR(1),  
                                    LocalBanx     CHAR(8), 
                                    NoCliente     CHAR(20), 
                                    Secuencia     SERIAL, 
                                    IdentAmor     CHAR(1),                                    
                                    Modifica      CHAR(4) );

        INSERT INTO bdinvers:sv_ocimn ( institucion, Operacion, Oficina, Importe, FechaIni, Famort, NoAmort, 
                              FechaVcto, FechaVctoAnt, Tasa, ForDetTasa, TasaDetTasa, PunTasa, FacTasa, 
                              RevTasa, ResParte, TipoParte, ParteOper, Moneda, OriRecur, AreaNeg, 
                              LocalBanx, NoCliente, IdentAmor, Modifica )        
        SELECT CASE WHEN ( NVL(inv.capital,0)= 0) Or (nvl(inv.fecha_alta, '') = '') THEN
                     '999999'  --DATOS INSUFICIENTES
                ELSE '040137' END Institucion, 
                '130', 'R', (inv.capital / 1000), inv.fecha_alta, 'U', '', inv.fecha_venc, '', inv.tasa, 
                'F', 0, '', '', '', 'M', 'F', '', ins.moneda, '', 'V', ciu.localidad_banxico, inv.num_cte, 
                '1', '' 
        FROM sv_fechas fec, sv_maeinv inv 
        INNER JOIN bdinvers:sv_instrum ins  ON  ins.cod_instrum = inv.cod_instrum 
        INNER JOIN bdinteg:si_ptf suc ON suc.id_ptf = inv.sucursal and suc.tipo in('S', 'X','O') 
        INNER JOIN bdinteg:si_ciudades ciu ON ciu.ciudad = suc.cve_ciudad and ciu.estado = suc.cve_estado 
        WHERE inv.fecha_alta = fec.fecha_ant AND inv.status_cta = '1';
        --ORDER BY inv.num_cte
        
    Let v_directorio   =  "/tmp/ocimn.txt";
    Let vsql = '';

    Let  vsql = 'echo "UNLOAD TO '   || (v_directorio) ||
                'SELECT institucion, Operacion, Oficina, Importe,  to_char(FechaIni, ''' || '%Y/%m/%d' || ''' ), Famort, NoAmort,  to_char(FechaVcto,''' || '%Y/%m/%d' || ''' ),   to_char(FechaVctoAnt, ''' || '%Y/%m/%d' || ''' ), Tasa::char(14), ForDetTasa, TasaDetTasa::char(14), PunTasa, FacTasa, RevTasa, ResParte, TipoParte, ParteOper, Moneda, OriRecur, AreaNeg, LocalBanx, NoCliente, Secuencia, IdentAmor, Modifica   FROM bdinvers:sv_ocimn" > /tmp/ocimn.sql';

    SYSTEM vsql;
    Let vsql = '';
    Let vsql = "dbaccess bdinvers /tmp/ocimn.sql ";

    SYSTEM vsql;
    DROP TABLE bdinvers:sv_ocimn;
END;
---Elaborado por : Aymme Osuna/Sistemas Desarrollo
--Modifico:        Armando Merado
--Fecha:           2007/12/26
--Razon:           Se modifican decimales en el campo Importe a 10 dig. y 1 Dec. con redondeo de dec.
END PROCEDURE;