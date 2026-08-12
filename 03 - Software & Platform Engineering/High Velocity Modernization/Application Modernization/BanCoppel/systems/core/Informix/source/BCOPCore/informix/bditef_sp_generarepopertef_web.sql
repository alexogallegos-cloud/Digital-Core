CREATE PROCEDURE "informix".sp_generarepopertef_web(pSucursal CHAR (4),
                                                pFechaConsulta DATE,
						                        pRegistros INTEGER)
--1 CVE RASTREO
--2 CTA 
--3 TARJETA

 RETURNING
 --CHAR(5), CHAR(10), CHAR (30), CHAR (30), CHAR (20), CHAR (10), 	
 CHAR(5), DATE, CHAR (30), CHAR (30), CHAR (20), CHAR (10),  
 CHAR (20), CHAR (50), CHAR (8), CHAR (9); 
				   
				   
--DEFINICION DE VARIABLES
    DEFINE iSqlErr               INTEGER;
    DEFINE cCodRet               CHAR (5);
	
    DEFINE cNombre_Cte_Ord       CHAR (30);
	DEFINE cNum_Cta_Ord          CHAR (20);
	DEFINE cImporte_Tef          CHAR (10);
	DEFINE cClave_Rastreo        CHAR (30);
	DEFINE cStatusPago           CHAR (2);
	DEFINE cDescStatusPago       CHAR (20);
	DEFINE cDescMotivoDev        CHAR (50);
	DEFINE cMotivoDev            CHAR (2);
	DEFINE iContador             INTEGER;
	DEFINE cNumCte               CHAR (9);
	DEFINE cUsuario              CHAR (8);
	DEFINE dFecha                CHAR (10);
	DEFINE iCuantos				 INTEGER;	
	
	
    --SET DEBUG FILE TO "sp_GeneraRepOperTEF.out";
    --TRACE ON;
	 
--INICIALIZACION DE VARIABLES
    LET cCodRet              = "00000";
	LET iSqlErr              = 0;
	LET cClave_Rastreo       = "";
	LET cNum_Cta_Ord         = "";
	LET cNombre_Cte_Ord      = "";
	LET cImporte_Tef         = "0.00";
	LET cStatusPago          = "";
	LET cDescStatusPago      = "";
	LET cMotivoDev           = "";
	LET cDescMotivoDev       = "";
	LET iContador            = 0;
	LET cNumCte              = "";
	LET cUsuario             = "";
    LET dFecha               = "01-01-1900";
	LET iCuantos			 = 0;
	
	
     

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte;  
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pSucursal IS NULL OR pSucursal = "" OR pFechaConsulta IS NULL OR pFechaConsulta = "" OR
	    pRegistros IS NULL OR pRegistros = "" THEN
	    LET cCodRet = "00001";
		RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte;   
		
	END IF;
	
	SELECT COUNT(*) 
	INTO iCuantos			
	FROM bditef:"informix".tef_operaciones
	WHERE sucursal = pSucursal
	AND cve_status <> '04'
	AND fecha_trans  = pFechaConsulta;
			
	IF iCuantos = 0 THEN
	    LET cCodRet = "00001";
		RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte;  
	END IF;
	


	    FOREACH
				
			SELECT fecha_trans, clave_rastreo, nombre_cte_ord, num_cta_ord, importe_tef, 
			      cve_status, motivo_dev, user_insert 
			INTO dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
                   cStatusPago, cMotivoDev, cUsuario			
			FROM bditef:"informix".tef_operaciones
			WHERE sucursal = pSucursal
			AND cve_status <> '04'
			AND fecha_trans  = pFechaConsulta
			
			
			SELECT descripcion
			INTO cDescStatusPago
			FROM bditef:"informix".tef_status_pago 
			WHERE  cve_status = cStatusPago;
			
			
			SELECT descripcion
			INTO cDescMotivoDev
			FROM bditef:"informix".tef_cat_devoluciones 
			WHERE  motivo_dev = cMotivoDev;
			
			
			SELECT num_cte 
			INTO cNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta = TRIM(cNum_Cta_Ord);
			
			LET iContador = iContador + 1;
				
			IF iContador <= pRegistros THEN
	            CONTINUE FOREACH;
	        END IF;
				
			RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte WITH RESUME;   
				
		END FOREACH;

 END;
			   
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener los datos para el reporte de operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110401',
    'BD    : bditef';

CREATE PROCEDURE "informix".cal_fecha_pre_fh_web(
			v_fechai char(10))
                       	RETURNING char(5),date;  

   DEFINE v_codret 	char(5);
   DEFINE v_fecha_pre 	date;
   DEFINE v_esferiado 	char(1);
   DEFINE v_bandera	char(1);
   DEFINE v_fecha	date;
   DEFINE sql_err,isam_err int;   

--set debug file to "/tmp/cal_fecha_pre_fh.out";
--trace on;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "00000";
   LET v_fecha_pre = " ";
   LET v_esferiado = "0";

-- ****************************************************************************
-- valida datos de entrada
-- ****************************************************************************

	IF  	v_fechai is null THEN
		-- datos de entrada incompletos   
		LET v_codret = 110; 
		RETURN v_codret,v_fecha_pre; 
	END IF;


BEGIN

	on exception set sql_err,isam_err
	if sql_err <> 0 or isam_err <> 0 then
	 let v_codret = sql_err;
	 return v_codret,v_fecha_pre;
	end if;
	end exception;
	
	LET v_fecha = to_date(v_fechai,"%m/%d/%Y");

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	select "1"
	into v_esferiado
	from bdinteg:si_feriado
	where fecha=v_fecha;
	
	IF v_esferiado is null THEN
		LET v_esferiado = "0";
	END IF

	IF v_esferiado <>"1" and to_char(v_fecha,"%A") <> "Saturday" and to_char(v_fecha,"%A") <> "Sunday"  THEN
		LET v_fecha = v_fecha + 1;
	END IF


	IF v_esferiado = "1"   THEN
		LET v_fecha = v_fecha + 1;
	END IF

	IF to_char(v_fecha,"%A") = "Saturday"  THEN
		LET v_fecha = v_fecha + 2;	
	END IF
	
	IF to_char(v_fecha,"%A") = "Sunday"  THEN
		LET v_fecha = v_fecha + 1;
	END IF

	-- barrer hasta obtener el sig. habil

	LET v_bandera = "0";
	WHILE v_bandera = "0"
		
		-- validar si es feriado la nueva fecha
		select "1"
		into v_esferiado
		from bdinteg:si_feriado
		where fecha=v_fecha;
		
		IF v_esferiado is null THEN
			LET v_esferiado = "0";
		END IF
		
		IF v_esferiado <> "1" and to_char(v_fecha,"%A") <> "Saturday" and to_char(v_fecha,"%A") <> "Sunday" THEN
			-- salir
			LET v_bandera = "1";		
		ELSE
			
			LET v_fecha = v_fecha + 1;
		END IF
	
	END WHILE

	LET v_fecha_pre = v_fecha;
END;    
RETURN v_codret,v_fecha_pre;
END PROCEDURE;