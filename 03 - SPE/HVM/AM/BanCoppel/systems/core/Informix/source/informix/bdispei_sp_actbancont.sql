CREATE PROCEDURE "informix".sp_actbancont(v_fecha DATE, v_usuario VARCHAR(8), v_bandera INT)
returning CHAR(5);
/*DEFINICION DE VARIABLES*/
DEFINE		vchrcod_ret		CHAR(5);
DEFINE	 	sql_err			INTEGER;
DEFINE	 	vintflag		INTEGER;
DEFINE		verror_info		VARCHAR(100);
DEFINE		vintflag_param	INTEGER;
--SET DEBUG FILE TO "/informix/ifg/sp_actbancont.out";
--TRACE ON;

/*INICIALIZACIÃN DE VARABLES*/
LET		vchrcod_ret = '00000';
LET	 	sql_err = 0;
LET	 	vintflag = 1;
LET 	verror_info = '';
	BEGIN
	/**/
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
			 LET vchrcod_ret = sql_err;
			 RETURN vchrcod_ret;
		  END IF
		END EXCEPTION;
		
		IF (v_fecha IS NULL  OR v_fecha != TODAY OR v_fecha = '') THEN
			LET verror_info = 'Error en la fecha';
			LET vchrcod_ret = '22221';
		ELSE 
				IF (v_usuario IS NULL OR v_usuario = '') THEN
					LET verror_info = 'Error en el usuario';
					LET vchrcod_ret = '22222';
				ELSE
					IF (v_bandera IS NULL OR v_bandera = '') THEN
						LET verror_info = 'Error en la bandera';
						LET vchrcod_ret = '22223';
					END IF;
				END IF;
		END IF;
		
		SELECT chreditable
			  INTO vintflag_param
		FROM "informix".tblparametros WHERE vchrcveparametro = 'BANDERA_ALERTA';
		
		IF (v_bandera != 1 AND v_bandera != 0 ) THEN
			LET verror_info = 'Error en la Bandera';
			LET vchrcod_ret = '22223';
		ELSE
			LET verror_info = 'Bandera correcta';
			LET vchrcod_ret = '00000';
		END IF;
		
		IF vchrcod_ret = '00000' THEN
				IF vintflag_param = v_bandera THEN
					LET verror_info = 'Error en la bandera igual al tblparametros';
					LET vchrcod_ret = '01110';
				ELSE
					INSERT INTO tblbitalertaspei (fech_alert, usr_alert, bandera)
						 VALUES (CURRENT, v_usuario, v_bandera);
					UPDATE tblparametros SET chreditable = v_bandera
						 WHERE vchrcveparametro = 'BANDERA_ALERTA';
					LET verror_info = 'ActualizaciÃ³n exitosa';
					LET vchrcod_ret = '00000';
				END IF;
		ELSE
			LET vchrcod_ret = '01110';	
		END IF;
		RETURN vchrcod_ret;
	END
END PROCEDURE
DOCUMENT
'CREADO POR: ISRAEL FLORES GONZÃÂLEZ',
'FECHA DE CREACIÃN:09 DE ABRIL DE 2018',
'OBJETIVO: SE CREA EL SP PARA INSERTAR REGITRO EN TABLA',
'          tblbitalertaspei PARA INDICAR QUE USUARIO Y ',
'          CUANDO SE ACTIVO Ã DESACTIVO LA CONTINGENCIA',
'          Y ACTUALIZAR LA BANDERA EN LA TABLA DE PARAMETROS',
'BD: BDISPEI';

CREATE PROCEDURE "informix".sp_consbancont()
returning CHAR(5);
DEFINE		vchrcod_ret		CHAR(5);
DEFINE	 	sql_err			INTEGER;
DEFINE	 	vintflag		INTEGER;
--    SET DEBUG FILE TO "/informix/ifg/sp_consbancont.out";
--    TRACE ON;
/*INICIALIZACIÓN DE VARABLES*/
LET		vchrcod_ret = '00000';
LET	 	sql_err = 0;
LET	 	vintflag = 1;
	BEGIN
	/**/
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
			 let vchrcod_ret = sql_err;
			 RETURN vchrcod_ret;
		  END IF
		END EXCEPTION;
		
		SELECT chreditable
			  INTO vintflag
		FROM "informix".tblparametros WHERE vchrcveparametro = 'BANDERA_ALERTA';
		
		IF vintflag = 0 THEN
			LET vchrcod_ret = '00000';
		ELSE
			LET vchrcod_ret = '01110';
		END IF;
		RETURN vchrcod_ret;
	END
END PROCEDURE
DOCUMENT
'CREADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE CREACIÓN:09 DE ABRIL DE 2018',
'OBJETIVO: SE CREA EL SP PARA LEER EL CAMPO chreditable',
'          DE LA TABLA tblparametros EL CUAL VA A INDICAR',
'          SI SPEI TIENE CONTIGENCIA',
'BD: BDISPEI';

CREATE PROCEDURE "informix".spei_apgbanope()
RETURNING CHAR(5), CHAR(100);
--------------------------------------------------------------------------------
---- Q25 La informaciÃ³n obtenida de este proceso corresponde a Pagos GDF, Pagos telmex,
---- Dish,  mastv, Ordenes pago, etc
---- Ejecucion diaria que es llamada por un proceso central (bi_q25_bi_servicio_central.sql)
--------------------------------------------------------------------------------
--Definimos variables
DEFINE var_valor					CHAR(1);
DEFINE vcodret 						CHAR(5);
DEFINE vSqlErr						INTEGER; 
DEFINE isam_err						INTEGER; 
DEFINE error_info					CHAR(100);
--Variables control
LET	var_valor = '';
LET	vcodret = '00000';
LET vSqlErr = 0; 
LET error_info = 'INICIA PROCESO';
--Se genera el log en un archivo .out
--SET DEBUG FILE TO "/ifxstag01/board/datos/bi_q25_servicios.out";
--TRACE ON;
--Inciamos el SP
BEGIN
--Controlamos las excepciones
       ON EXCEPTION SET vsqlerr, isam_err, error_info
       SET LOCK MODE TO wait 5;

       SET ISOLATION TO DIRTY READ;
			   IF vsqlerr <> 0  THEN
						 LET vcodret = vsqlerr;
						 LET isam_err = isam_err;
						 LET error_info = error_info;
				RETURN vcodret, error_info;
			  END IF;
	  END EXCEPTION;
	  
	  --Se verifica el valor de la bandera
	  SELECT vchrvalor 
		INTO var_valor
			FROM "informix".tblparametros
     WHERE  vchrcveparametro = 'BLOQUEO_A_USUARIOS';

	 IF var_valor = 1 THEN
			UPDATE "informix".tblparametros SET vchrvalor = 0
					WHERE  vchrcveparametro = 'BLOQUEO_A_USUARIOS';
			LET vcodret = '00000';
			LET error_info = 'PROCESO EXITOSO';
	 ELSE
			IF var_valor = 0 THEN
				LET vcodret = '01110';
				LET error_info = 'LA BANDERA YA ESTA APAGADA';
			ELSE 
					IF (var_valor < 0) OR (var_valor > 1) THEN
							LET vcodret = '11110';
							LET error_info = 'VALOR ACTUAL ERRORNEO:'|| var_valor||' FAVOR DE VALIDAR';
					END IF;
			END IF;
	END IF;
	RETURN vcodret, error_info;
	
	END
END PROCEDURE
DOCUMENT
'CREADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE CREACIÃN: 18 JUNIO DE 2018',
'OBJETIVO: ENCENDER LA BANDARA PARA QUE NO ENTREN TRANSACCIONES',
'          SPEI',
'BD: BDISPEI';

CREATE PROCEDURE "informix".spei_encbanope()
RETURNING CHAR(5), CHAR(100);
--------------------------------------------------------------------------------
---- Q25 La informaciÃ³n obtenida de este proceso corresponde a Pagos GDF, Pagos telmex,
---- Dish,  mastv, Ordenes pago, etc
---- Ejecucion diaria que es llamada por un proceso central (bi_q25_bi_servicio_central.sql)
--------------------------------------------------------------------------------
--Definimos variables
DEFINE var_valor					CHAR(1);
DEFINE vcodret 						CHAR(5);
DEFINE vSqlErr						INTEGER; 
DEFINE isam_err						INTEGER; 
DEFINE error_info					CHAR(100);
--Variables control
LET	var_valor = '';
LET	vcodret = '00000';
LET vSqlErr = 0; 
LET error_info = 'INICIA PROCESO';
--Se genera el log en un archivo .out
--SET DEBUG FILE TO "/ifxstag01/board/datos/bi_q25_servicios.out";
--TRACE ON;
--Inciamos el SP
BEGIN
--Controlamos las excepciones
       ON EXCEPTION SET vsqlerr, isam_err, error_info
       SET LOCK MODE TO wait 5;

       SET ISOLATION TO DIRTY READ;
			   IF vsqlerr <> 0  THEN
						 LET vcodret = vsqlerr;
						 LET isam_err = isam_err;
						 LET error_info = error_info;
				RETURN vcodret, error_info;
			  END IF;
	  END EXCEPTION;
	  
	  --Se verifica el valor de la bandera
	  SELECT vchrvalor 
		INTO var_valor
			FROM "informix".tblparametros
     WHERE  vchrcveparametro = 'BLOQUEO_A_USUARIOS';

	 IF var_valor = 0 THEN
			UPDATE "informix".tblparametros SET vchrvalor = 1
					WHERE  vchrcveparametro = 'BLOQUEO_A_USUARIOS';
			LET vcodret = '00000';
			LET error_info = 'PROCESO EXITOSO';
	 ELSE
			IF var_valor = 1 THEN
				LET vcodret = '01110';
				LET error_info = 'LA BANDERA YA ESTA PRENDIDA';
			ELSE 
					IF (var_valor < 0) OR (var_valor > 1) THEN
							LET vcodret = '11110';
							LET error_info = 'VALOR ACTUAL ERRORNEO:'|| var_valor||' FAVOR DE VALIDAR';
					END IF;
			END IF;
	END IF;
	RETURN vcodret, error_info;
	
	END
END PROCEDURE
DOCUMENT
'CREADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE CREACIÃN: 18 JUNIO DE 2018',
'OBJETIVO: ENCENDER LA BANDARA PARA QUE NO ENTREN TRANSACCIONES',
'          SPEI',
'BD: BDISPEI';

CREATE PROCEDURE "informix".sp_actualiza_msjs_spei(pempresa CHAR(3))
RETURNING CHAR(5), INTEGER;

    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE iComienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    
    DEFINE dFechaHoy    DATE;
    DEFINE cNumCte      CHAR(20);
    DEFINE cTipoMsj     CHAR(1);
    DEFINE cStr1        CHAR(30);
    DEFINE cStr2        CHAR(30);
    DEFINE cStr3        CHAR(30);
    DEFINE cStr4        CHAR(30);
    DEFINE cStr5        CHAR(150);
    DEFINE dFecha1      DATETIME YEAR TO FRACTION(3);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET iContador1   = 0;
    LET iContador2   = 0;
    LET iComienza    = -1;
    LET iTransacc    = 0;
    
    LET dFechaHoy = '';
    LET cNumCte   = '';
    LET cTipoMsj  = '';
    LET cStr1     = '';
    LET cStr2     = '';
    LET cStr3     = '';
    LET cStr4     = '';
    LET cStr5     = '';
    LET dFecha1   = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_msjs_spei.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET cCodRet1 = sql_err;
            LET cCodRet2 = isam_err;
            LET cCodRet3 = desc_err;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_msjs_spei.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tbl_registro_msj idxtbl_registro_msj)}
               pnumclt, ptipomsj, pstr1, pstr2, pstr3, pstr4, pstr5, pfecha1
          INTO cNumCte, cTipoMsj, cStr1, cStr2, cStr3, cStr4, cStr5, dFecha1
          FROM tbl_registro_msj
         WHERE pnumclt >= '000001002'
           AND ptipomsj IN('1','2')
           AND pfecha1::date < dFechaHoy
           AND pstatus = 'A'
           
        IF iComienza = -1 THEN
            LET iComienza =  0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
         
        UPDATE {+INDEX(tbl_registro_msj idxtbl_registro_msj)} tbl_registro_msj
           SET pstatus = 'E'
         WHERE pnumclt = cNumCte
           AND ptipomsj = cTipoMsj
           AND pfecha1 = dFecha1
           AND pstatus = 'A'
           AND pstr1 = cStr1
           AND pstr2 = cStr2
           AND pstr3 = cStr3
           AND pstr4 = cStr4
           AND pstr5 = cStr5;
        
        LET iContador1 = iContador1 + 1;
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 500 THEN
            LET iContador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;            
        
        LET cNumCte  = '';
        LET cTipoMsj = '';
        LET cStr1    = '';
        LET cStr2    = '';
        LET cStr3    = '';
        LET cStr4    = '';
        LET cStr5    = '';
        LET dFecha1  = '';
    END FOREACH;
     
    IF iTransacc = 1 THEN
        LET iTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN cCodRet1, iContador1;
    
END PROCEDURE;