CREATE PROCEDURE "informix".sp_alteratipodatofustelefonos()
RETURNING CHAR(5) AS CodRet;

    -- // Definicion de Variables
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE cNumCte      CHAR(20);
    DEFINE cTelefono    CHAR(13);
    DEFINE siTipoTel    SMALLINT;
    DEFINE siSecuencia  SMALLINT;
    DEFINE cFechaHora   CHAR(23);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcontador    INTEGER;

    -- // Inicializacion de Variables
    LET iSqlErr     = 0;
    LET iIsamErr    = 0;
    LET cDescErr    = '';
    LET cCodRet     = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET vabierto    = '0';
    LET cNumCte     = '';
    LET cTelefono   = '';
    LET siTipoTel   = 0;
    LET siSecuencia = 0;
    LET cFechaHora  = '';
    LET vcomienza   = -1;
    LET vcontador   = 0;

    --SET DEBUG FILE TO '/tmp/sp_alteratipodatofustelefonos.out';
    --TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO '/tmp/sp_alteratipodatofustelefonos.err';
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // MODIFICACION EN si_telefonos
    ALTER TABLE "informix".si_fustelefonos ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;

    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_fustelefonos
         --WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;

        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);

        UPDATE "informix".si_fustelefonos 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;
    
    /*LET vcomienza = -1;
    LET vcontador = 0;
    
    -- // MODIFICACION EN si_telefonos_actual
    ALTER TABLE "informix".si_telefonos_actual ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;
    
    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_telefonos_actual
         WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;
        
        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);
        
        UPDATE "informix".si_telefonos_actual 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;*/
    
    ALTER TABLE "informix".si_fustelefonos DROP fecha_hora;
    RENAME COLUMN "informix".si_fustelefonos.fecha_completa TO fecha_hora;
    
    --ALTER TABLE "informix".si_telefonos_actual DROP fecha_hora;
    --RENAME COLUMN "informix".si_telefonos_actual.fecha_completa TO fecha_hora;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cambia el tipo de dato al campo fecha_hora de la tabla si_telefonos',
'AUTOR: Iris Arias Zazueta',
'FECHA: 07-01-2013',
'VERSION: 1.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_reporte_huellas_aut()
	RETURNING
		CHAR(6) 	AS 	COD_RET,
		CHAR(80) 	AS MENSAJE_RET;
		
		
	--DECLARACION DE VARIABLES
	DEFINE cCodret 		 	CHAR(6);
	DEFINE iSqlErr        	INTEGER;
	DEFINE cMensaje       	CHAR(80);
	DEFINE cNumCte1			CHAR(20);
	DEFINE cApellPat1		CHAR(26);
	DEFINE cApellMat1		CHAR(26);
	DEFINE cNom1			CHAR(26);
	DEFINE cNom2			CHAR(26);
	DEFINE cRFC1			CHAR(13);
	DEFINE dtFechaNac1		DATE;
	DEFINE cNumCte2			VARCHAR(9);
	DEFINE cApellPat2		CHAR(26);
	DEFINE cApellMat2		CHAR(26);
	DEFINE cNom1_2			CHAR(26);
	DEFINE cNom2_2			CHAR(26);
	DEFINE cRFC2			CHAR(13);
	DEFINE dtFechaNac2		DATE;
	DEFINE cTicket			CHAR(20);
	DEFINE dtFechaCons		DATE;
	DEFINE dPorce			DECIMAL;
	DEFINE dtFechaInsert	DATE;
	DEFINE iDia         	INTEGER;
	
	
	DEFINE dFechaIni	DATE;
	DEFINE dFechaFin	DATE;
	DEFINE dFechaAux	DATE;
	
	
	

	--INICIALIZACION DE VARIABLES
	LET cCodret			= '00000';
	LET iSqlErr 		= 0;
	LET cMensaje		= 'PROCESO EXITOSO';
	LET cNumCte1		= '';
	LET cApellPat1		= '';
	LET cApellMat1		= '';
	LET cNom1			= '';
	LET cNom2			= '';
	LET cRFC1			= '';
	LET dtFechaNac1		= DATE(1);
	LET cNumCte2		= '';
	LET cApellPat2		= '';
	LET cApellMat2		= '';
	LET cNom1_2			= '';
	LET cNom2_2			= '';
	LET cRFC2			= '';
	LET dtFechaNac2		= DATE(1);
	LET cTicket			= '';
	LET dtFechaCons		= DATE(1);
	LET dPorce			= 0.0;
	LET dtFechaInsert	= DATE(1);


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET cMensaje = "ERROR NO CONTROLADO";
			RETURN cCodret, cMensaje;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT day(fecha_hoy)  INTO  iDia FROM bdinteg:si_fechas;
	
	IF (iDia) <= 15 THEN --Reporte del 16 al 30
		SELECT   date( month(fecha) || '/16/' || year(fecha) ),fecha    INTO dFechaIni,dFechaFin
		FROM TABLE (multiset(
			select date(pri_dia_mes - interval(1) DAY TO DAY) as fecha  from bdinteg:si_fechas));
			
	ELIF (iDia) > 15 THEN --Reporte del 01 al 15
		SELECT pri_dia_mes, date( month(pri_dia_mes) || '/15/' || year(pri_dia_mes) )   INTO dFechaIni,dFechaFin FROM bdinteg:si_fechas;
		
	END IF;	
	
	--SET DEBUG FILE TO "/informix/ArmandoM/sp_huella_linea.out";
	--TRACE ON;

		SELECT DISTINCT LPAD(TRIM(cliente::CHAR(9)), 9,'0') numcte2, a.ticket, a.fecha, cte1.apell_paterno apell_pat_2, cte1.apell_materno apell_mat_2, cte1.nombre1 nom1_2, cte1.nombre2 nom2_2, cte1.rfc rfc_2, pf.fecha_nac fecha_nac2
		FROM si_huella_linea_resultado a,  si_cliente cte1, si_ctepf pf
		WHERE fecha  between dFechaIni and dFechaFin    -- parametro de entrada
		AND num_mensaje = '602' AND cliente <> '0' AND a.empresa = '5' AND pf.fecha_nac <= '01-01-1995'
		AND LPAD(TRIM(cliente::CHAR(9)), 9,'0') = cte1.numcte AND LPAD(TRIM(cliente::CHAR(9)), 9,'0') = pf.numcte

		INTO temp clientes_bcpl_dupl_2 WITH NO LOG;

		SET ISOLATION TO DIRTY READ;
		SELECT a.numcte numcte1, a.fecha_consulta, a.ticket, cte1.apell_paterno apell_pat_1, cte1.apell_materno apell_mat_1, cte1.nombre1 nom1_1, cte1.nombre2 nom2_1, cte1.rfc rfc_1, pf.fecha_nac fecha_nac1
		FROM si_huella_linea a, si_cliente cte1, si_ctepf pf
		WHERE (fecha_consulta between dFechaIni and dFechaFin) AND ticket IN
		(SELECT ticket FROM clientes_bcpl_dupl_2) AND a.numcte = cte1.numcte  AND a.numcte = pf.numcte
		
		INTO temp clientes_bcpl_dupl_1 WITH NO LOG;

		INSERT INTO si_clientes_huellas_dupl(numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1, rfc_1, fecha_nac1, numcte2, apell_pat_2, apell_mat_2, nom1_2, nom2_2, rfc_2, fecha_nac2, ticket, fecha_consulta, fecha_insert)
			SELECT a.numcte1, a.apell_pat_1, a.apell_mat_1, a.nom1_1, a.nom2_1, a.rfc_1, a.fecha_nac1, b.numcte2, b.apell_pat_2, b.apell_mat_2, b.nom1_2, b.nom2_2, b.rfc_2, b.fecha_nac2, a.ticket, a.fecha_consulta, CURRENT AS fecha_insert
			FROM clientes_bcpl_dupl_1 a, clientes_bcpl_dupl_2 b
			WHERE a.ticket = b.ticket 
			AND b.fecha = a.fecha_consulta;
			
			
		EXECUTE PROCEDURE "informix".sp_compara_nombres()
		INTO cCodret;
	
		RETURN cCodret, cMensaje;
	END;	
END PROCEDURE;