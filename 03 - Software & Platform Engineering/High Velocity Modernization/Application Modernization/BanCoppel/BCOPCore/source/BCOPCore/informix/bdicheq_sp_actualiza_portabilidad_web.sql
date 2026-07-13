CREATE PROCEDURE "informix".sp_actualiza_portabilidad_web(pEmpresa CHAR(3), 
													  pFolio CHAR(30), 
													  pClaveOrigen CHAR(1),
													  pEstatusPortabilidad CHAR(2), 
													  pSucursal CHAR(4), 
													  pUserInsert CHAR(8), 
													  pEstatus CHAR(2), 
													  pOrigenCancel CHAR(20), 
                                                      pFolioCancel CHAR(30))
RETURNING CHAR(5);

--Declaracion de variables
DEFINE cCodRet 		CHAR(10);
DEFINE iTransaccion INTEGER;
DEFINE iSqlErr 		INTEGER;
DEFINE cFecha		DATE;
DEFINE cNumCte		CHAR(10);
DEFINE cNumCtaCbe	CHAR(18);
DEFINE cCuenta		CHAR(20);
DEFINE dFecha		CHAR(10);
DEFINE cCodRetSP    CHAR(5);
DEFINE cMenRetSp    CHAR(100);

--Asignacion de variables
LET cCodRet 	 = '00000';
LET iTransaccion = 0;
LET iSqlErr 	 = 0;
LET cFecha	 	 = DATE(1);
LET dFecha 		 = '01/01/1990';

LET cNumCte		 = '';
LET cNumCtaCbe	 = '';
LET cCuenta	 	 = '';
LET cCodRetSP 	 = '00000';
LET cMenRetSp    = '';

BEGIN

    ON EXCEPTION SET iSqlErr --Manejador de Errores	
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;


            END IF;
			RETURN cCodRet;
        END IF;		
    END EXCEPTION;
	
    ON EXCEPTION IN (-535)
       LET iTransaccion = 1;
       COMMIT WORK;
       BEGIN WORK;
    END EXCEPTION WITH RESUME;
	


    BEGIN WORK;



        
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/sp_actualiza_portabilidad.out";
	--TRACE ON;

    IF NVL(pEmpresa, '') = '' OR  NVL(pFolio, '') = '' OR NVL(pClaveOrigen, '') = ''  OR  NVL(pEstatusPortabilidad, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pUserInsert, '') = '' OR NVL(pEstatus, '') = '' OR NVL(pOrigenCancel, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
		LET cCodRet = '01288';       
		RETURN cCodRet;
    END IF;

	SELECT fecha_hoy
	INTO cFecha

	FROM bdicheq:"informix".sc_fechas 
	WHERE empresa = pEmpresa;

	LET dFecha = TO_CHAR(cFecha, '%Y%m%d');
			
	SELECT num_cte, cta_ordenante
	INTO cNumCte, cNumCtaCbe
	FROM bdicheq:"informix".sc_portacec_solicitud 
	WHERE empresa = '001'
	AND folio_solicitud = pFolio;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "01289";
		RETURN cCodRet;
	END IF;
	
	SELECT cuenta
	INTO cCuenta
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta_clabe = cNumCtaCbe;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "01289";
		RETURN cCodRet;
	END IF;
	
	UPDATE bdicheq:"informix".sc_portacec_solicitud  
	SET clave_origen = '1', estatus_portabilidad = '4', clave_sentido = '0',
		fecha_estatus_portabilidad = dFecha, suc_cancela = pSucursal, 
		user_cancela = pUserInsert, fecha_solca_portabilidad = dFecha,
		folio_cancelacion= pFolioCancel
	WHERE  empresa = pEmpresa AND folio_solicitud = pFolio; 
	
/*
	UPDATE bdicheq:"informix".sc_portabilidadnomina  
	SET estatus = '02', user_cancel = pUserInsert, 
		fecha_cancel = dFecha, origen_cancel = 'OFI', 
		sucursal_cancel = pSucursal 
	WHERE empresa = pEmpresa 
	AND cliente = cNumCte
	AND cuenta_abono = cCuenta
	AND secuencia = (SELECT MAX(secuencia) 
							FROM bdicheq:"informix".sc_portabilidadnomina 
							WHERE empresa = pEmpresa 
							AND cuenta_abono = cCuenta);	
*/

    EXECUTE PROCEDURE bdicheq:sp_PortabCancela(cNumCte, cCuenta, 'OFI', pSucursal, pUserInsert)
    INTO cCodRetSP, cMenRetSp;

    IF cCodRetSP <> '00000' THEN
        LET cCodRet = '01280';
    END IF;

    IF  iTransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
       COMMIT WORK;
    END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para que actualice la informacion cuando se realice una cancelacion de portabilidad de nomina.",
"Codigos de Error: ",
"",
"			cCodRet = 01288 Parametros de Entrada vacios, verifique.",
"			cCodRet = 01289 No existe informacion. Favor de verificar",
"",			
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 27/08/2015",
"BD     : bdicheq";

CREATE PROCEDURE "informix".firmantes_web(pempresa char(3),pcuenta char(20),psecuencia smallint,pnumcte char(20),papellidos char(30),
pnombre char(30),preg_firma char(1),ptipo_firma char(1),pcombinacion char(120),pparentesco char(2))

returning char(5);

define cod_ret     char(5);
define longitud    smallint;
define vnum_cte    char(20);
define vtipocte    char(1);
define sql_err,
       isam_err    integer;

define v_long_cta  CHAR(2);

let vtipocte ="";
begin

   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   let cod_ret="00000";

   if pcuenta is null or
      psecuencia is null or
        pnumcte is null or
      pparentesco is null  then
        let cod_ret="00110";
        return cod_ret;
   end if

   if psecuencia = 1 then
      delete from sc_firmantes
      where empresa = pempresa and cuenta = pcuenta ;
   end if;

   select num_cte into vnum_cte
   from sc_maechq where cuenta = pcuenta;

   if not vnum_cte is null then
      select tipo_cliente into vtipocte
      from   bdinteg:si_cliente
      where  numcte = vnum_cte;
   end if

   insert into sc_firmantes (empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco)
                     values (pempresa,pcuenta,psecuencia,pnumcte,papellidos,pnombre,preg_firma,ptipo_firma,pcombinacion,pparentesco);

--   IF Trim(pparentesco) <> "" THEN
      insert into bdinteg:si_cterelacionado
          (empresa,numcte,sistema,cuenta,
          tipo_relacion,parentesco,
          tipo_cliente_ori,user_insert,
          fecha_insert)
      values (pempresa,pnumcte,"SC",pcuenta,
          "02",pparentesco,vtipocte,USER,
           current);
--   END IF;
   
   --Actualiza el Maenoc por las Firmas Registradas
   UPDATE sc_maenoc SET reg_firmas = psecuencia
   WHERE  cuenta = pcuenta;

   return cod_ret;
end;
end procedure;