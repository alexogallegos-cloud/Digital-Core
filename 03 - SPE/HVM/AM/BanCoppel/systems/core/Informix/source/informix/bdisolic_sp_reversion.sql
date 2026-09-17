CREATE PROCEDURE "informix".sp_reversion(P_EMPRESA              CHAR(3),         
      P_NUM_SOLICITUD 	     CHAR(20))                                    
   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret     CHAR(5);
   DEFINE p_mensaje   CHAR(80);

   LET cod_ret = '000';
   LET p_mensaje = 'Operacion terminada Exitosamente';
      /* Borra datos de las garantías de la solicitud */  
      DELETE FROM bdigaran:SG_FINAN 
      WHERE  EMPRESA     = P_EMPRESA 
      AND    NUM_CREDITO = P_NUM_SOLICITUD;    
      DELETE FROM bdigaran:SG_COMER              
      WHERE  EMPRESA     = P_EMPRESA                
      AND    NUM_CREDITO = P_NUM_SOLICITUD; 
      DELETE FROM bdigaran:SG_HIPOT                             
      WHERE  EMPRESA     = P_EMPRESA                                    
      AND    NUM_CREDITO = P_NUM_SOLICITUD;   
      DELETE FROM bdigaran:SG_SEGUR             
      WHERE  EMPRESA     = P_EMPRESA         
      AND    NUM_CREDITO = P_NUM_SOLICITUD;    
      DELETE FROM bdigaran:SG_PREND              
      WHERE  EMPRESA     = P_EMPRESA         
      AND    NUM_CREDITO = P_NUM_SOLICITUD;  
      DELETE FROM bdigaran:SG_FIDUC          
      WHERE  EMPRESA     = P_EMPRESA   
      AND    NUM_CREDITO = P_NUM_SOLICITUD;     
      DELETE FROM bdigaran:SG_MAEGARAN          
      WHERE  EMPRESA     = P_EMPRESA 
      AND    NUM_CREDITO = P_NUM_SOLICITUD;  
      /* Borra datos de la solicitud */
      DELETE FROM SS_UNIDADPROD       
      WHERE  EMPRESA       = P_EMPRESA
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD;   
      DELETE FROM SS_REFCOMERCIAL     
      WHERE  EMPRESA       = P_EMPRESA  
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD; 
      DELETE FROM SS_CONCEPFINAO      
      WHERE  EMPRESA       = P_EMPRESA      
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD; 
      DELETE FROM SS_CONCEPFINA        
      WHERE  EMPRESA       = P_EMPRESA   
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD;
      DELETE FROM bdicred:SD_DETDOCUM
      WHERE  EMPRESA       = P_EMPRESA
      AND    NUM_CREDITO   = P_NUM_SOLICITUD;                   
      DELETE FROM SS_DETMINIS               
      WHERE  EMPRESA       = P_EMPRESA
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD;  
      DELETE FROM SS_ANEXOSOL         
      WHERE  EMPRESA       = P_EMPRESA  
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD;
      DELETE FROM SS_SOLICITUDES    
      WHERE  EMPRESA       = P_EMPRESA
      AND    NUM_SOLICITUD = P_NUM_SOLICITUD;

      RETURN cod_ret, p_mensaje;
END PROCEDURE;