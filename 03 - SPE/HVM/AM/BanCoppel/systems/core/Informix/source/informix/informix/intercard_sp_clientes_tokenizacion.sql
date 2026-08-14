CREATE PROCEDURE "informix".sp_clientes_tokenizacion()

RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************
DEFINE iSql_err                                         INT;
DEFINE cCodRet                                          CHAR(5);
DEFINE vNumtarjeta                      VARCHAR(19);
DEFINE vCliente                                         VARCHAR(20);
DEFINE vCodStatus                                       VARCHAR(4);
DEFINE vCCredito                                        VARCHAR(20);
DEFINE vStatusCred                                      VARCHAR(3);
DEFINE vCDebito                                         VARCHAR(20);
DEFINE vStatusDeb                                       VARCHAR(1);
DEFINE vFecha                                           DATETIME YEAR TO FRACTION(5);
DEFINE banderaDeb                                       INTEGER;
DEFINE banderaCred                                      INTEGER;
DEFINE contador                     INTEGER;
DEFINE nombreArchivo                VARCHAR(60);
DEFINE pArchDeclarga1                   CHAR(1000);
DEFINE cCmd1                            CHAR(1500);
DEFINE cQuery1                          CHAR(3000);
DEFINE primerDiaMes                     CHAR(2);
DEFINE mes                              CHAR(2);
DEFINE anio                             CHAR(4);
DEFINE anioAnt                      CHAR(4);
DEFINE horaInicio                       CHAR(11);
DEFINE cardID                                           CHAR(100);
DEFINE fechaExp                     CHAR(4);
DEFINE mesAnt                           CHAR(2);

-- ****************************************************************************
-- Inicializa las variables
-- ****************************************************************************
LET iSql_err                                    = 0;
LET cCodRet                                             = '00000';
LET vNumtarjeta                                 = '';
LET vCliente                                    = '';
LET vCodStatus                                  = '';
LET vCCredito                   = '';
LET vStatusCred                                 = '';
LET vCDebito                                    = '';
LET vStatusDeb                                  = '';
LET vFecha                                              = '';
LET banderaDeb                                  = 0;
LET banderaCred                                 = 0;
LET contador                    = 0;
LET nombreArchivo               = '';
LET primerDiaMes                = '';
LET mes                         = '';
LET anio                        = '';
LET horaInicio                              = ' 00:00:00.0';
LET cardID                                              = '';
LET fechaExp                    = '';
LET mesAnt                      = '';
LET anioAnt                     = '';

    BEGIN

                ON EXCEPTION SET iSql_err

                        IF iSql_err <> 0 then
                                LET cCodRet = iSql_err;
                                RETURN cCodRet;
                        END IF;
                END EXCEPTION;

                SET ISOLATION TO dirty READ;
                SET LOCK MODE TO WAIT 3;
                --SET DEBUG FILE TO "/home/syscybmdp2/prueba_sp_clientes_tokenizacion.out";
        --TRACE ON;

                TRUNCATE TABLE intercard:tbl_ciclo_vida_tokenizacion_clientes;

                --Consulta el primer dia del mes
        LET primerDiaMes = "01";


        SELECT MONTH(TODAY),MONTH(TODAY) -1,YEAR(TODAY),YEAR(TODAY) -1
            INTO mes,mesAnt,anio,anioAnt
        FROM systables
            WHERE tabid=1;

        IF mes < 10 THEN
            LET mes = 0 || mes;
        END IF

        IF mesAnt < 10 THEN
            LET mesAnt = 0 || mesAnt;
        END IF




        ----Fecha y hora inicio mes anterior----
        LET vFecha = trim(anio ||'-'|| mes || '-' || primerDiaMes || horaInicio);

                FOREACH tarjetas WITH HOLD FOR

                        SELECT DISTINCT tar.numcliente
                                INTO vCliente
                                        FROM intercard:tarjetas_tokenizadas ind
                                                INNER JOIN intercard:tarjeta tar
                                                        ON ind.numtarjeta = tar.numtarjeta
                                                                WHERE tar.fechaultmodif < vFecha
                                                                        AND ind.status = 5
                                                                                AND tar.numcliente <> ""

                        LET banderaDeb = 0;
                        LET banderaCred = 0;

                        FOREACH tarjetas WITH HOLD FOR

                                SELECT num_credito, status_cred
                                        INTO vCCredito, vStatusCred
                                                FROM bdicred:sd_maecred
                                                        WHERE numcte = vCliente

                                IF (vCCredito IS NOT NULL) THEN
                                        IF (vStatusCred NOT IN ('FI', 'FF', 'CV', 'FC', 'FM', 'CE', 'FR', 'FE', 'OE')) THEN
                                                LET banderaCred = 1;
                                        END IF
                                END IF

                        END FOREACH

                        FOREACH tarjetas WITH HOLD FOR

                                SELECT cuenta, status_cta
                                        INTO vCDebito, vStatusDeb
                                                FROM bdicheq:sc_maechq
                                                        WHERE num_cte = vCliente

                                IF (vCDebito IS NOT NULL) THEN
                                        IF (vStatusDeb NOT IN ('2' , '4', '6', '3')) THEN
                                                LET banderaDeb = 1;
                                        END IF
                                END IF

                        END FOREACH

                        IF (banderaDeb = 0 AND banderaCred = 0) THEN
                                INSERT INTO "informix".tbl_ciclo_vida_tokenizacion_clientes(numcliente, reason, reasoncode)
                                        VALUES(vCliente, 'Cancelacion de cuentas', 'ISSUER_DECISION');
                        END IF

                END FOREACH
                IF mesAnt = 0 THEN
			LET fechaExp =  SUBSTR(anioAnt,3,2) || 12;
		ELSE
			LET fechaExp =  SUBSTR(anio,3,2) || mesAnt;
		END IF

                
                --TRACE "FECHA : " || fechaExp;
                FOREACH tarjetas WITH HOLD FOR

            SELECT card_id
                INTO cardID
            FROM tarjeta tar
                INNER JOIN tokenizacion_cardid tok
                    ON tok.numtarjeta = tar.numtarjeta
            WHERE tar.fechaexp = fechaExp
            AND tar.codstatustarjeta IN ("ACT","BLO")

                        --TRACE cardID;

                         IF (cardID IS NOT NULL OR cardID <> '') THEN
                INSERT INTO  tbl_ciclo_vida_tokenizacion_clientes(numcliente, reason, reasoncode)
                VALUES(cardID, 'EXPIRADA', 'ISSUER_DECISION');
             END IF

                END FOREACH

                SELECT COUNT(*)
                        INTO contador
                                        FROM tbl_ciclo_vida_tokenizacion_clientes;

                IF (contador > 0) THEN
                        LET nombreArchivo = 'Ciclo_Vida_Tokenizacion_Clientes_';

                        LET pArchDeclarga1='"/RESPALDOSNEW/Tokenizacion/'|| nombreArchivo ||  anio || '-' || mes || '-04.csv" ';

                        LET cCmd1 = 'SELECT TRIM(numcliente), reason, reasoncode FROM tbl_ciclo_vida_tokenizacion_clientes;';
                        LET cQuery1 = "echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' > /RESPALDOSNEW/Tokenizacion/tmp_tokenizacion_clientes.sql";
                        SYSTEM TRIM(cQuery1);
                        SYSTEM 'dbaccess intercard /RESPALDOSNEW/Tokenizacion/tmp_tokenizacion_clientes.sql';
                ELSE
                        LET cCodRet = "00002";
                END IF;



        RETURN cCodRet;
        END;

END PROCEDURE;