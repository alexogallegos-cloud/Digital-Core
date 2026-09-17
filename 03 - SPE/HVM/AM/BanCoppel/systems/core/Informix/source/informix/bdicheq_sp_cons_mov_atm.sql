CREATE PROCEDURE "informix".sp_cons_mov_atm( pempresa char(10), pnum_tarjeta char(16), pterm_id char(10))

RETURNING CHAR(5), CHAR(10), CHAR(40), CHAR(40),CHAR(40),CHAR(40),CHAR(40),CHAR(40);
	
    --VARIABLES DE CONTROL DE ERRORES
    DEFINE iSqlErr		INTEGER;		
    DEFINE vIsamErr		INTEGER;
    DEFINE vpaso		INTEGER;
    DEFINE vErrorInfo	VARCHAR(90);
    
    --VARIABLES DE SALIDA
    DEFINE vCodRet  	CHAR(4);		
    DEFINE vfechamov    CHAR(10);
    DEFINE vreferencia  CHAR(40);
    DEFINE vdescripcion CHAR(50);
    DEFINE vsucursal    CHAR(50);
    DEFINE vtransacc    CHAR(40);
    DEFINE vretiro     	DECIMAL(14,2);
    DEFINE vdeposito    CHAR(40);
    DEFINE vsaldo       CHAR(40);
    DEFINE vmonto       CHAR(40);
    DEFINE vPagoMin     CHAR(40);
    DEFINE vSdoDeudor   CHAR(40);
    DEFINE vIntMora     DECIMAL(14,2);
    DEFINE vIvaIntMora  DECIMAL(14,2);
    
    --VARIABLES DE USO
    DEFINE vempresa     CHAR(10);
    DEFINE vnum_tarjeta	CHAR(16);
    DEFINE vterm_id     CHAR(10);
    DEFINE vnum_cuenta  CHAR(19);
    DEFINE vproducto    CHAR(2);
    DEFINE vciclo      SMALLINT;
    DEFINE vultmovto   SMALLINT;
	
	DEFINE vfecha_hoy	DATE;
	DEFINE vfecha_pmes	DATE;
	DEFINE vano	        varchar (4);
	DEFINE vmes	        varchar (2);
	DEFINE vdia         varchar (2);
	DEFINE vdma         varchar (8);
	DEFINE vdmar		varchar (10);

	DEFINE vano2        varchar (4);
	DEFINE vmes2        varchar (2);
	DEFINE vdia2        varchar (2);
	DEFINE vdma2        varchar (8);
	DEFINE vdmar2		varchar (10);
    
    -- SE INICIALIZA VARIABLES
    let vnum_tarjeta = pnum_tarjeta;
    let vterm_id 	= pterm_id;
    let vCodRet 	= '';
    let vfechamov 	= '';
    let vreferencia = '';
    let vdescripcion= '';
    let vretiro 	= 0;
    let vdeposito 	= 0; 
    let vsaldo 		= 0;
    let vsucursal 	= '';
    LET vtransacc 	= '';
    let vempresa 	= '001';
    LET vmonto      = 0;
    LET vPagoMin    = 0;
    LET vSdoDeudor  = 0;
    LET vIntMora    = 0;
    LET vIvaIntMora = 0;
    LET vciclo     	= 0;
    LET vultmovto  	= 4;
    
    --TRACE
    --SET DEBUG FILE TO "/informix/c98288075/sp_cons_mov_atm.out";
    --TRACE ON; 
    
    --INICIA PROCEDIMIENTO
    BEGIN
    
	ON EXCEPTION SET iSqlErr, vIsamErr
        IF iSqlErr != 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
        END IF;
    END EXCEPTION;
		
		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vpaso = 0;
    
    --Obtener nÃºmero de cuenta
    SELECT numcuenta 
        INTO vnum_cuenta 
    FROM intercard:tarjetacuenta 
    WHERE numtarjeta  = vnum_tarjeta; 
    
    IF (vnum_cuenta is NULL) THEN
        LET vnum_cuenta = '';
		RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
	END IF;
    
	SELECT creditodebito 
      INTO vproducto 
      FROM intercard:bines 
     WHERE SUBSTR(vnum_tarjeta,1,6) = bin;
    
    LET vpaso = 1;
    --Si es crÃ©dito		
		
		IF( vproducto = 'C') THEN 
			FOREACH
				EXECUTE PROCEDURE bdicred:consultmovs(vempresa,vnum_cuenta,'') 
				INTO vCodRet, vfechamov, vtransacc, vmonto, vPagoMin, vSdoDeudor, vIntMora, vIvaIntMora
				 RETURN vCodRet, vfechamov, SUBSTR(vtransacc,6,30), vmonto, vPagoMin, vSdoDeudor, vIntMora, vIvaIntMora WITH RESUME;
			END FOREACH;
		END IF;
    
    --Si es dÃ©bito
		
		IF( vproducto = 'D') THEN 
			
			SELECT fecha_hoy, pri_dia_mes INTO vfecha_hoy, vfecha_pmes 
			FROM bdinteg:si_fechas; 
		
		
			let vano =  SUBSTR(vfecha_hoy,9,2);
			let vmes =  SUBSTR(vfecha_hoy,1,2);
			let vdia =  SUBSTR(vfecha_hoy,4,2);
			let vfecha_hoy = vmes||'-'||vdia||'-'||vano;
			
			let vfecha_pmes = extend (vfecha_pmes - 1 units MONTH) - 0 units day;
			
			let vano2 = SUBSTR(vfecha_pmes,9,2);
			let vmes2 = SUBSTR(vfecha_pmes,1,2);
			let vdia2 = SUBSTR(vfecha_pmes,4,2);
			let vfecha_pmes =  vmes2||'-'||vdia2||'-'||vano2;
			
			
			
			
			FOREACH
				EXECUTE PROCEDURE bdicheq:sp_edoctamovimientos(vempresa, vnum_cuenta, vfecha_pmes, vfecha_hoy,0,'', '') 
				INTO vCodRet, vfechamov, vreferencia, vdescripcion, vretiro, vdeposito, vsaldo, vsucursal
				
			   RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal WITH RESUME;
				
				LET vciclo = vciclo+1;
				IF vciclo > vultmovto THEN
					EXIT FOREACH;
				END IF	
			END FOREACH;

		--	Si los SPL no regresan valores
			
			IF (vCodRet = '') THEN
				LET vCodRet = '777';
					RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
			END IF;


		END IF;
    END;
	
END PROCEDURE;