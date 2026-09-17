CREATE PROCEDURE "informix".sp_del_libromayor()

	DEFINE r_codret   CHAR(5);
    DEFINE r_mensaje  VARCHAR(255);
	
    SET ISOLATION TO DIRTY READ; 
	SET LOCK MODE TO WAIT 3;
    
	LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';
	
    BEGIN
        --co_libmadet   	
        DROP TABLE bdicont:"informix".co_libmadet;

        CREATE TABLE "informix".co_libmadet ( 
            empresa        	CHAR(3) NOT NULL,
            cuenta         	CHAR(60),
            ccmayor        	CHAR(10) NOT NULL,
            ccsub          	CHAR(10) NOT NULL,
            ccsubsub       	CHAR(10) NOT NULL,
            ccssubsub      	CHAR(10) NOT NULL,
            ccsssubsub     	CHAR(10) NOT NULL,
            sector         	CHAR(10) NOT NULL,
            ciudad         	CHAR(3) NOT NULL,
            sucursal       	CHAR(4),
            moneda         	CHAR(2) NOT NULL,
            fecha_valida   	DATE NOT NULL,
            usuario        	CHAR(8) NOT NULL,
            control_poliza 	INTEGER,
            secuencia      	INTEGER,
            nro_auxiliar   	CHAR(12),
            naturaleza     	CHAR(1),
            saldo_inicial  	MONEY NOT NULL,
            monto          	MONEY,
            saldo_final    	MONEY,
            descripcion_det	CHAR(50),
            fecha_captura  	DATE,
            ccosto_orig    	CHAR(4),
            usuario_rep    	CHAR(10),
            id_reporte     	INTEGER DEFAULT 0
            )EXTENT SIZE 7648 NEXT SIZE 768 LOCK MODE ROW;
        
        CREATE INDEX informix.idx01co_libmadet ON informix.co_libmadet(id_reporte,usuario_rep) FILLFACTOR 70 ONLINE;

        CREATE INDEX informix.idx02co_libmadet
        ON informix.co_libmadet(id_reporte,usuario_rep,sucursal,ciudad,moneda) FILLFACTOR 70 ONLINE;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".co_libmadet;

        --delete  co_libsdoaux
        DROP TABLE bdicont:"informix".co_libsdoaux;

        CREATE TABLE informix.co_libsdoaux ( 
            empresa        	CHAR(3),
            cuenta         	CHAR(60),
            ccmayor        	CHAR(10),
            ccsub          	CHAR(10),
            ccsubsub       	CHAR(10),
            ccssubsub      	CHAR(10),
            ccsssubsub     	CHAR(10),
            sector         	CHAR(10),
            ciudad         	CHAR(3),
            sucursal       	CHAR(4),
            moneda         	CHAR(2),
            fecha_valida   	DATE,
            usuario        	CHAR(8),
            control_poliza 	INTEGER,
            secuencia      	INTEGER,
            fecha_captura  	DATE,
            nro_auxiliar   	CHAR(12),
            naturaleza     	CHAR(1),
            saldo_inicial  	MONEY,
            monto          	MONEY,
            saldo_final    	MONEY,
            descripcion_det	CHAR(50),
            ccosto_orig    	CHAR(4),
            id_reporte     	INTEGER DEFAULT 0
            ) EXTENT SIZE 7360 NEXT SIZE 736 LOCK MODE ROW;

        CREATE INDEX informix.idx01co_libsdoaux ON informix.co_libsdoaux(id_reporte,usuario) FILLFACTOR 70 ONLINE;

        UPDATE STATISTICS MEDIUM FOR TABLE "informix".co_libsdoaux;

    END;
	
	EXECUTE PROCEDURE bdicont:sp_upd_co_auxiliar('001') INTO r_codret, r_mensaje;
	
END PROCEDURE;