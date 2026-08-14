Create Procedure "informix".sp_proac_estatus(pCuentaEje Char(20), pStatus Char(1))
--Returning char(6), char(100);

Define cod_ret Char(6);
Define sql_err integer;
Define isam_err integer;
Define iMax integer;

Let iMax = 0;

Begin
/*    --Trigger no debe tener return
   On Exception Set sql_err, isam_err
      If sql_err <> 0 Or isam_err <> 0 Then
         let cod_ret = sql_err;
         Return cod_ret, '';
      End if;
   End Exception;
*/
   --Set debug file to "/tmp/sp_EstatusProac.out";
   --Trace On;

   Let cod_ret = '000';
   Let iMax = 0;

   If length (pCuentaEje) > 0 And length (pStatus) >= 1 Then
        If pStatus in (1,3) Then

            --Actualiza el status de la cuenta proac con estaus de cuenta eje

            Select nvl(Max(secuencia),0) into iMax
            From bdicheq:sc_proac
            Where cta_eje = pCuentaEje
            And Status_cta in (1,3);

            Update bdicheq:sc_proac Set status_cta = pStatus
            Where cta_eje = pCuentaEje
            And status_cta in (1,3)
            And secuencia = iMax;

        End If;
    End if;
    --Return cod_ret, pStatus ;
End
End Procedure
DOCUMENT
'AUTOR      : Amando Mercado Figueroa',
'DESCRIPCION: Procedimiento que hereda el estatus de una cuenta eje a una cuneta proac, solo si es 1,3.',
'Captacion',
'FECHA      : Febrero de 2009',
'VERSION    : 20090223.2030',
'BD         : BDICHEQ',
'LLAMADO    : Se ejecuta del trigger tr_statusproac';

CREATE PROCEDURE "informix".sp_indicador_si_bpiusuarios( pTipo CHAR(1), pIdStatus SMALLINT, pCte CHAR(20) )
	
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
    DEFINE cCodRet2			CHAR(6);
	DEFINE cDescRet			CHAR(80);
    DEFINE dFechaHoy        DATE;
	DEFINE cAnioMesActual	CHAR(6);
	DEFINE cCuenta			CHAR(20);
	DEFINE iInternet		SMALLINT;
    DEFINE iExiste          SMALLINT;
    
	LET iSqlErr        = 0;
	LET iIsamErr       = 0;
	LET cErrorInfo     = '';
	LET cCodRet        = '';
    LET cCodRet2       = '';
	LET cDescRet	   = '';
    LET dFechaHoy      = '';
	LET cAnioMesActual = '';
	LET cCuenta		   = '';
	LET iInternet	   = 0;
    LET iExiste        = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_indicador_si_bpiusuarios.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
			LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSqlErr;
			LET cDescRet = cErrorInfo;
		END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_indicador_si_bpiusuarios.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
	SELECT fecha_hoy
	  INTO dFechaHoy
	  FROM sc_fechas
	 WHERE empresa = '001';
    
    LET cAnioMesActual = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0');
    
	LET pTipo = NVL(pTipo,'');
	LET pIdStatus = NVL(pIdStatus,0);
	LET pCte = NVL(pCte,'');
	
	IF pTipo = 'I' AND pIdStatus <> 99 THEN   
		FOREACH
            SELECT cuenta
			  INTO cCuenta
			  FROM sc_maechq
			 WHERE num_cte = pCte
             
            SELECT {+INDEX(sc_indicadores idx_indicadores_aniomes_cta)} 
                   COUNT(*)
              INTO iExiste
              FROM sc_indicadores
             WHERE anio_mes = cAnioMesActual
               AND cuenta = cCuenta;
               
            IF iExiste > 0 THEN
                UPDATE sc_indicadores
                   SET internet = 1
                 WHERE anio_mes = cAnioMesActual
                   AND cuenta = cCuenta;
            END IF;
            
            LET iExiste = 0;
            LET cCuenta = '';
		END FOREACH
	ELIF pTipo = 'U' THEN
		IF pIdStatus = 99 THEN
			LET iInternet = 0;
		ELSE
			LET iInternet = 1;
		END IF
        
		FOREACH               
            SELECT cuenta
			  INTO cCuenta
			  FROM sc_maechq
			 WHERE num_cte = pCte
             
            SELECT {+INDEX(sc_indicadores idx_indicadores_aniomes_cta)} 
                   COUNT(*)
              INTO iExiste
              FROM sc_indicadores
             WHERE anio_mes = cAnioMesActual
               AND cuenta = cCuenta;
               
			IF iExiste > 0 THEN
                UPDATE sc_indicadores
                   SET internet = iInternet
                 WHERE anio_mes = cAnioMesActual
                   AND cuenta = cCuenta;
            END IF;
            
            LET iExiste = 0;
            LET cCuenta = '';
		END FOREACH
	END IF;
	
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para ',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_insertar_sc_transacc_indicadores_pba
(
pEmpresa 		CHAR(3),
pNumero  		CHAR(4),
pSeEmiteEdoCta	CHAR(1)
)
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
	IF NVL(pSeEmiteEdoCta,"") = "S" THEN

		INSERT INTO "informix".sc_transacc_indicadores (empresa, numero)
		VALUES (pEmpresa, pNumero);

	END IF

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro en los indicadores de la cuenta recien abierta',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Enero 2014';

CREATE PROCEDURE "informix".sp_insertar_sc_transacc_indicadores
(
pEmpresa 		CHAR(3),
pNumero  		CHAR(4),
pSeEmiteEdoCta	CHAR(1),
pSistema		CHAR(2)
)
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
	IF NVL(pSeEmiteEdoCta,"") = "S" AND pSistema = "01" THEN

		INSERT INTO "informix".sc_transacc_indicadores (empresa, numero)
		VALUES (pEmpresa, pNumero);

	END IF

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro en los indicadores de la cuenta recien abierta',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Enero 2014';

CREATE PROCEDURE "informix".sp_depura_sc_movhis_old(fecha_depurar DATE);
   define vcuenta char(20);
   let vcuenta = '';
   set isolation to dirty read;
   set lock mode to wait;
   FOREACH cursor_borra WITH HOLD FOR
                select {+INDEX (sc_movhis_old idx_movhis)} cuenta 
                  into vcuenta
                  FROM sc_movhis_old
                  WHERE empresa = '001'
                   AND cuenta between '10000000000' and '99099999999'
                   AND fech_alt =  fecha_depurar
           BEGIN WORK;
              DELETE FROM sc_movhis_old WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
   END FOREACH
END PROCEDURE;