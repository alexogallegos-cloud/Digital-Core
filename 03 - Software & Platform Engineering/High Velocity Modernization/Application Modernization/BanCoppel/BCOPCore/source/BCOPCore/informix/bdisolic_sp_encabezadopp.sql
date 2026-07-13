CREATE PROCEDURE "informix".sp_encabezadopp(empresa CHAR(3), pNumCte CHAR(9), pNumSolicitud CHAR(20),pProducto CHAR(4),pTipo CHAR(1))

RETURNING   CHAR(5)  AS Codret,
                           CHAR(20) AS plazo,
                           CHAR(20) AS capacidad_pres,
                           CHAR(20) AS monto_autorizado,
                           DECIMAL(18,2) AS monto_solicitado,
                           DECIMAL(18,2) AS monto_min_cred,
                           DECIMAL(18,2) AS monto_max_cred,
                           INTEGER AS plazomax,
						   INTEGER AS plazomin,
                           INTEGER AS plazolinea;

    --definicion de variables
    DEFINE cCodret				CHAR(5);
	DEFINE sql_err				INTEGER;
	DEFINE cPlazo 	 			INTEGER;
	DEFINE cCapacidad_pres		DECIMAL(18,2);
	DEFINE cMonto_autorizado	DECIMAL(18,2);
	DEFINE cMonto_solicitado	DECIMAL(18,2);
	DEFINE cMtomin				DECIMAL(18,2);
	DEFINE cMtomax				DECIMAL(18,2);
	DEFINE cPzomax				INTEGER;
	DEFINE cPzomin				INTEGER;
    DEFINE cPzolinea     	 	INTEGER; --CR 01-nov-17
    DEFINE dFechaSolic          DATE; -- FMV 26-sep-13
    DEFINE dFechaModif_Montos   DATE; -- FMV 26-sep-13
    DEFINE cMonto_min_disp      DECIMAL(18,2);
 

	LET cCodret 			= "00000";
	LET sql_err	    		= 0;
	LET cPlazo              = "";
	LET cCapacidad_pres     = "";
	LET cMonto_autorizado 	= "";
	LET cMonto_solicitado	= "";
    LET dFechaSolic         = DATE(1);  
    LET dFechaModif_Montos  = DATE(1);
    LET cMonto_min_disp     = "";
    LET cPzolinea           = "";

        
        BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodret = sql_err;
				RETURN cCodret,cPlazo,cCapacidad_pres, cMonto_autorizado,cMonto_solicitado,cMtomin, cMtomax, cPzomax,cPzomin,cPzolinea WITH RESUME;
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
                --SET DEBUG FILE TO "/tmp/sp_encabezadopp.out";
                --TRACE ON;


                IF pTipo = '1' THEN
        		IF NVL(pNumCte, '') = '' OR NVL(pNumSolicitud, '') = '' OR NVL(pProducto,'') = '' THEN
                		LET cCodret = '00110';
                        	RETURN cCodret,'','','','','','','','','';
                        END IF
                END IF;
			
                SELECT plazo,capacidad_pres, monto_autorizado, monto_solicitado, fecha_insert
                INTO cPlazo,cCapacidad_pres, cMonto_autorizado,cMonto_solicitado, dFechaSolic
                FROM bdisolic:ss_solicitudes
                WHERE numcte = pNumCte
                AND num_solicitud = pNumSolicitud;

                SELECT monto_min_cred, monto_max_cred, plazo_max_cred, plazo_min_cred, plazo_linea, f_modifica_montos, monto_min_disp
                INTO cMtomin, cMtomax, cPzomax, cPzomin, cPzolinea, dFechaModif_Montos, cMonto_min_disp
                FROM bdicred:sd_definicion
                WHERE num_producto = pProducto;
           
                --FMV 10-OCT-13: El monto minimo disponible para Prestamo Personal y CredinÃ³mina, es de $1,000.00
				LET cMtomin = cMonto_min_disp;   --FMV 10-OCT-13
				
                RETURN cCodret,cPlazo,cCapacidad_pres, cMonto_autorizado,cMonto_solicitado,cMtomin, cMtomax, cPzomax, cPzomin, cPzolinea WITH RESUME;
	END;
END PROCEDURE
