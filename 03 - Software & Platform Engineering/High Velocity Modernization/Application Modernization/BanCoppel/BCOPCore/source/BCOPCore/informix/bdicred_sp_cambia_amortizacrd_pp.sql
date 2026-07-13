CREATE PROCEDURE "informix".sp_cambia_amortizacrd_pp(p_fecha_alta_apoyo date)
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,              
              CHAR(25) AS StorePro,
              CHAR(20) AS prestamo;              
              

   DEFINE vsqlerr           INTEGER; 

   DEFINE v_codigo_retorno	CHAR(5);
   DEFINE v_mensaje	  	    CHAR(80);
   DEFINE v_store_pro       CHAR(25);
   DEFINE vc_prestamo       char(20);
  
   DEFINE vc_num_credito  CHAR(20);
   DEFINE vd_fecha_cuota DATE;
   DEFINE vd_fecha_cuota_new DATE;
   DEFINE vd_fecha_alta_apoyo DATE;
   DEFINE vd_fecha_vencim12 DATE;
   DEFINE vd_fecha_vencim12_new DATE;
   DEFINE vd_fecha_venc_anexo DATE;
   DEFINE vd_fecha_venc_anexo_new DATE;

          --SET debug file TO "/tmp/sp_cambia_amortizacrd_pp.out";
          --TRACE ON;

             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente";
             
             LET v_store_pro = 'sp_cambia_amortizacrd_pp';
             LET vc_num_credito = '';
             let vc_prestamo = '';
             LET vd_fecha_cuota =  DATE(1);
             LET vd_fecha_cuota_new = DATE(1);
             LET vd_fecha_alta_apoyo = p_fecha_alta_apoyo;
             LET vd_fecha_vencim12 = DATE(1);
             LET vd_fecha_vencim12_new = DATE(1);
             LET vd_fecha_venc_anexo = DATE(1);
             LET vd_fecha_venc_anexo_new = DATE(1);
 
            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";            
            LET v_store_pro = 'sp_cambia_amortizacrd_pp';
            LET vc_prestamo = vc_num_credito;
         RETURN v_codigo_retorno, v_mensaje,  v_store_pro, vc_prestamo ;
        END IF;
   END EXCEPTION;


           FOREACH WITH HOLD                                         
                    SELECT num_credito, fecha_vencim
                      INTO vc_num_credito, vd_fecha_vencim12
                      FROM "informix".sd_maecredcrd WHERE empresa = '001' and num_credito in
                          (SELECT a.num_credito FROM "informix".sd_programa_apoyo2013crd a
                                                WHERE fecha_alta = p_fecha_alta_apoyo)
                      AND status_cred <> 'FF'
                   
                        LET vc_prestamo =  vc_num_credito;   

                                SELECT fecha_vencto  --nvl(fecha_vencto,date(1))
                                  INTO vd_fecha_venc_anexo
                                  FROM "informix".sd_maecredanexocrd 
                                 WHERE empresa = '001' 
                                   AND num_credito = vc_num_credito; 

                                SELECT max(fecha_cuota)
                                  INTO  vd_fecha_cuota 
                                  FROM "informix".sd_amortiza_creditocrd
                                 WHERE empresa = '001'
                                   AND num_credito = vc_num_credito;           
                    
                        IF vd_fecha_cuota <>  DATE(1) THEN            
                            CALL "informix".monthadd(vd_fecha_cuota,+3) RETURNING vd_fecha_cuota_new;        --sd_amortizacrd
                            CALL "informix".monthadd(vd_fecha_vencim12,+3) RETURNING vd_fecha_vencim12_new;  --sd_maecredcrd      

                            IF vd_fecha_venc_anexo IS NOT NULL THEN
                                CALL "informix".monthadd(vd_fecha_venc_anexo,+3) RETURNING vd_fecha_venc_anexo_new;  --sd_maecredanexocrd
                            ELSE 
                               LET vd_fecha_venc_anexo_new = vd_fecha_venc_anexo;

                            END IF;     


                                      BEGIN WORK;
                                           UPDATE "informix".sd_amortiza_creditocrd
                                              SET fecha_cuota = vd_fecha_cuota_new                                                  
                                            WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito
                                              AND fecha_cuota = vd_fecha_cuota;                  

                                          UPDATE  "informix".sd_maecredcrd
                                             SET  fecha_pago_cap = vd_fecha_cuota_new,
                                                  fecha_pago_int = vd_fecha_cuota_new,
                                                  fecha_vencim   = vd_fecha_vencim12_new                                                   
                                             WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito;


                                          UPDATE "informix".sd_maecredanexocrd
                                             SET fecha_vencto = vd_fecha_venc_anexo_new                                                                                          
                                             WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito;
        
                                     COMMIT WORK;                                            
                       END IF;               
               
           END FOREACH;                            
                   
                     LET v_codigo_retorno = "00000";
                     LET v_mensaje = "Proceso de Actualizacion, Termino Correctamente!";                     
                     LET v_store_pro = 'sp_cambia_amortizacrd_pp';
                   
      
 END;   --begin      
      RETURN v_codigo_retorno, v_mensaje, v_store_pro, vc_prestamo;

END PROCEDURE;