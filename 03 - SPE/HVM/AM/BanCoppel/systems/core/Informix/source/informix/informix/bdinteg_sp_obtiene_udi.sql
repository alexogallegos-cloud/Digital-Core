CREATE PROCEDURE "informix".sp_obtiene_udi(pFecha date)

 RETURNING CHAR(5) as Codigo, CHAR (300) as Mensaje, DATE as fecha_UDI;

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE v_Codret1    CHAR(5);
    DEFINE v_Codret     CHAR(5);
    
    DEFINE pEmpresa         CHAR(3);
    DEFINE vPrecio_udi      DECIMAL(14,6);
    DEFINE vTope_udis       DECIMAL (16,0);
    DEFINE vId_canal        CHAR(2);
    DEFINE vMensaje         CHAR (300);
    DEFINE vLim_canal_udis  DECIMAL (16,0);
    
    DEFINE vFechaPaso	      DATE;
    DEFINE vRestriccion     CHAR (2);
    
    LET sql_err     = 0;
    LET isam_err    = 0;
    LET v_Codret1   = '00000';
    LET v_Codret    = '';
    LET vMensaje    = 'El proceso concluyó exitosamente';
    
    LET pEmpresa          = '001';
    LET vPrecio_udi       = 0.00; 
    LET vTope_udis        = 0.00; 
    LET vId_canal         = '';
    LET vLim_canal_udis   = 0; 
    
    LET vFechaPaso        = "";
    LET vRestriccion      = '';
     --**************************************************************
     -- Creado por Raúl Ramírez    01/Jul/2010         
     -- Obtinen la UDI vigente y Convierte el UDI al Maximo de Pesos
     --**************************************************************


BEGIN

   ON EXCEPTION SET sql_err
            --SET DEBUG FILE TO "/ids10_uc9/raul/capitulox/obtiene_udi.err";
            --TRACE ON;
      IF sql_err <> 0  THEN
         LET v_Codret1 = sql_err;
         LET v_Codret1 = v_Codret1;
        -- ROLLBACK WORK;
         --RETURN v_Codret;
      END IF
   END EXCEPTION;
               --SET DEBUG FILE TO "/ids10_uc9/raul/capitulox/obtiene_udi.out";
               --TRACE ON;


---  Obtiene la UDI reciente
          
        EXECUTE PROCEDURE intercard:"informix".sp_obtener_udi(pEmpresa, pFecha)
                     INTO v_Codret, vPrecio_udi, vFechaPaso;

---  Convierte las UDIS a Pesos Maximos
    FOREACH                            
        SELECT {+index (si_plimites idx_plimites)} tope_max_udis, id_canal, id_restriccion
          INTO vTope_udis, vId_canal, vRestriccion
          FROM bdinteg:si_plimites


	             IF vTope_udis = 0 OR vTope_udis is NULL THEN
		              CONTINUE FOREACH;		
	                ELSE
		                IF vTope_udis > 0 THEN

		                UPDATE {+index (si_plimites idx_plimites)} bdinteg:si_plimites
		                   SET tope_max_pesos = (vPrecio_udi * vTope_udis)
		                 WHERE id_canal = vId_canal
                       AND id_restriccion = vRestriccion;
		                END IF;
	              END IF;
    END FOREACH;
---  Actualiza las UDIS a la fecha más reciente
    FOREACH
        SELECT {+index (si_canales idx_canal)} limite_canal_udis, id_canal
          INTO vLim_canal_udis, vId_canal
          FROM bdinteg:si_canales

          
	             IF vLim_canal_udis = 0 OR vLim_canal_udis is NULL THEN
		              CONTINUE FOREACH;		
	                ELSE
		               IF vLim_canal_udis > 0 THEN

		               UPDATE {+index (si_canales idx_canal)} bdinteg:si_canales
		                  SET limite_canal_pesos = (vPrecio_udi * vLim_canal_udis)
		                WHERE id_canal = vId_canal;
		               END IF;
	             END IF;
    END FOREACH;

END
   RETURN v_Codret1, vMensaje, vFechaPaso;
   
END PROCEDURE;