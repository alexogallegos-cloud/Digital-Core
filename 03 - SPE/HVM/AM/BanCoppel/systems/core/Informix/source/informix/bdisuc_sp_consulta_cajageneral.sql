CREATE PROCEDURE "informix".sp_consulta_cajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS cIdProvCaja,
		CHAR(30) AS cDescCaja;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cIdProvCaja CHAR(4);
		DEFINE cDescCaja CHAR(30);
        DEFINE cPlazaCaja CHAR(3);
        DEFINE iNoRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cIdProvCaja = '';
        LET cDescCaja = '';
        LET cPlazaCaja = '';
        LET iNoRegistros = 0;


        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_cajageneral.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = ''  THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

				SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                -- COMBOBOX CAJA GENERAL
			FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
                INTO cIdProvCaja, cDescCaja, cPlazaCaja 
                FROM bdisuc:"informix".ss_proveedores ORDER BY UPPER(descripcion)

                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;   
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/09/2018',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Aumento Resta de Saldos Caja General',
'AUTOR: ING. JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/07/2023',
'DESCRIPCION: MODIFICACIÃN Se le agrego la paginaciÃ³n a la consulta.',
'BD: bdisuc';

CREATE PROCEDURE  "informix".sp_valfcfs_web_pbatrace(pusuario         char(4),
                                  pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             SMALLINT;

   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE vexiste           SMALLINT; 

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret           = "00000";
   LET vfecha_central    = "";

      SET DEBUG FILE TO "/DBA/INC/20240518/RESPALDO/bdisuc.sp_valfcfs_web.240518_trace.out";
      TRACE ON;


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF;
   END EXCEPTION;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "00110";
         RETURN cod_ret,vfecha_central,vexiste;
      END IF
      
-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   
   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdicont:co_fechas;
   
   IF EXISTS(SELECT usuario FROM bdicont:co_poldet_20240518 WHERE usuario = pusuario AND  
                     fecha_captura = pfecha_sucursal AND fecha_valida = vfecha_central) THEN
      LET vexiste = 0;
   ELSE
      LET vexiste = 1;
   END IF;
  

   IF not vfecha_central > pfecha_sucursal THEN
      --RETURN cod_ret,vfecha_central,vexiste;
   --ELSE
      LET vfecha_central = pfecha_sucursal;
   END IF;
    
    RETURN cod_ret,vfecha_central,vexiste;
END
END PROCEDURE;