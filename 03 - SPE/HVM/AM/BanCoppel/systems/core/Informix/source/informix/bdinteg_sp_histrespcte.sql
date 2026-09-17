CREATE PROCEDURE "informix".sp_histrespcte(p_Tipo INTEGER, p_FechaIni DATE, p_FechaFin DATE)
RETURNING
    CHAR(5); ---cod_ret

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
    DEFINE vDiaHoy              INTEGER;
    DEFINE vMesHoy              INTEGER;
    DEFINE vAnioHoy             INTEGER;
    DEFINE iFlag                INTEGER;
    DEFINE vFechaHoy            DATE;

     LET v_cod_ret  = '00009';
     LET iFlag  = 0;

    --SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;

    ---SET DEBUG FILE TO "/tmp/sp_histrespcte.out";
    ---TRACE ON;

     SELECT fecha_hoy 
     INTO   vFechaHoy
     FROM   si_fechas;

     LET vDiaHoy   = Day(vFechaHoy);
     LET vMesHoy   = Month(vFechaHoy);
     LET vAnioHoy  = Year(vFechaHoy);

     IF p_FechaIni > vFechaHoy THEN
        LET v_cod_ret ='00001';
     ELSE
         IF p_FechaFin > vFechaHoy THEN
            LET v_cod_ret ='00002';
         ELSE
             IF p_FechaIni > p_FechaFin THEN
                LET v_cod_ret ='00003';
             END IF; 
         END IF;
     END IF;

     IF p_Tipo = 1 AND v_cod_ret ='00009' THEN    
         IF vDiaHoy < 21 THEN
            IF vMesHoy = 1 THEN
               IF p_FechaIni BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy) - 1 units  month)::date, day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy -1))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                  LET v_cod_ret ='00004';
               ELSE
                   IF p_FechaFin BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy) - 1 units  month)::date, day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy -1))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                      LET v_cod_ret ='00005';
                   ELSE
                        SELECT limit 1 1 
                        INTO   iFlag
                        FROM   bitacora_edocta 
                        WHERE  fecha BETWEEN p_FechaIni And p_FechaFin;
                        
                        IF iFlag = 1 THEN   
                           INSERT INTO bitacorahis_edocta(num_credito, sucursal, fecha, cajero, respuesta) 
                           SELECT num_credito, sucursal, fecha, cajero, respuesta
                           FROM   bitacora_edocta
                           WHERE  fecha BETWEEN p_FechaIni And p_FechaFin;

                           DELETE FROM bitacora_edocta Where fecha BETWEEN p_FechaIni And p_FechaFin;
                           LET v_cod_ret ='00000';
                        ELSE
                            LET v_cod_ret ='00006'; 
                        END IF; 
                   END IF;
               END IF;
            ELSE
                IF p_FechaIni BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy) - 1 units  month)::date, day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                   LET v_cod_ret ='00004';
                ELSE
                    IF p_FechaFin BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy) - 1 units  month)::date, day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                       LET v_cod_ret ='00005';
                    ELSE
                        SELECT limit 1 1 
                        INTO   iFlag
                        FROM   bitacora_edocta 
                        WHERE  fecha BETWEEN p_FechaIni And p_FechaFin;
                        
                        IF iFlag = 1 THEN   
                           INSERT INTO bitacorahis_edocta(num_credito, sucursal, fecha, cajero, respuesta) 
                           SELECT num_credito, sucursal, fecha, cajero, respuesta
                           FROM   bitacora_edocta
                           WHERE  fecha BETWEEN p_FechaIni And p_FechaFin;

                           DELETE FROM bitacora_edocta Where fecha BETWEEN p_FechaIni And p_FechaFin;
                           LET v_cod_ret ='00000';
                        ELSE
                            LET v_cod_ret ='00006'; 
                        END IF; 
                    END IF;
                END IF;
            END IF;
         ELSE                                          
             IF p_FechaIni BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy)), day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                LET v_cod_ret ='00004';
             ELSE
                 IF p_FechaFin BETWEEN mdy(month ( mdy(vMesHoy,vDiaHoy,vAnioHoy)), day(mdy(1,21,1900) ),year(mdy(vMesHoy,vDiaHoy,vAnioHoy))) And mdy(vMesHoy,20,vAnioHoy)  THEN
                    LET v_cod_ret ='00005';
                 ELSE
                     SELECT limit 1 1 
                     INTO   iFlag
                     FROM   bitacora_edocta 
                     WHERE  fecha Between p_FechaIni And p_FechaFin;
                        
                     IF iFlag = 1 THEN   
                        INSERT INTO bitacorahis_edocta(num_credito, sucursal, fecha, cajero, respuesta) 
                        SELECT num_credito, sucursal, fecha, cajero, respuesta
                        FROM   bitacora_edocta
                        WHERE  fecha BETWEEN p_FechaIni And p_FechaFin;

                        DELETE FROM bitacora_edocta Where fecha BETWEEN p_FechaIni And p_FechaFin;
                        LET v_cod_ret ='00000';
                     ELSE
                         LET v_cod_ret ='00006'; 
                     END IF; 
                 END IF;
             END IF;
         END IF;
    END IF;
 
    RETURN v_cod_ret;

END;
--******************************************************
--| Procedimiento : sp_histrespcte
--| Creado por    : Saúl Ivanhoe
--| Fecha         : 20 - Mayo - 2009
--| Descripción   : Historico Pregunta Edo. Cuenta 
--******************************************************
END PROCEDURE;