CREATE PROCEDURE "informix".sp_replicacionmisbpi_rep(pFechaRep date, pFechaReal date, vhora char(7))
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha1          char(18);
DEFINE  dFecha2          datetime year to second;
DEFINE  dFecha           Date;
DEFINE  iVal             INTEGER;

/*Variables para formateo de pFecha*/
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_idia CHAR(2);
DEFINE v_iMesc CHAR(2);

DEFINE v_hora          CHAR(7);
DEFINE pFecha date;
/***********************************/

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- Creado por Manuel Osuna                                   --*              
-- Debug del Procedure                                       --*
 --SET DEBUG FILE TO "/home/informix/jydg/sp_replicacionmisbpi_rep.out";                      --*
 --TRACE ON;                                                 --*
--**************************************************************

--  pFechaRep  Fecha en la que se acerca el resultado de los datos, de acuerdo a los dias ya ejecutados
--  pFechaReal Fecha que aparece en los datos del reproceso 
--  phora      Horario de ejecución del proceso del mis donde se puede manipular para que se acerque el resultado de los datos de acuerdo a los dias ya ejecutados


   LET iVal = 0;
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

/*Formateo de pFecha*/

    set isolation to dirty read;
    LET v_iAnio = 0;
    LET v_iMes = 0;
    LET v_idia = 0;
    LET v_iMesc = '01';

    LET pFecha = pFechaReal;
    LET v_iAnio = YEAR(pFecha);
    LET v_iMes = LPAD(MONTH(pFecha),2,0);
    LET v_idia = LPAD(DAY(pFecha),2,0);


    if v_iMes < 10 then 
        LET v_iMesc= 0||v_iMes;
    else 
        LET v_iMesc= v_iMes;
    end if;

    LET dFecha = pFechaRep;
--    LET dFecha1 = v_iMesc||'/'||v_idia||'/'||v_iAnio;
    --LET dFecha1 = v_iMesc||v_idia||v_iAnio||' '||vhora;
    LET dFecha1 = v_iAnio||'-'||v_iMesc||'-'||v_idia||' '||vhora;
    LET dFecha1 = dFecha1;

    LET dFecha2 = dFecha1::datetime year to second;
    LET dFecha2 = dFecha2;

    /********************/

    --SELECT fecha_ant INTO dFecha FROM bdmis:mi_fechas;

    IF NOT EXISTS (SELECT fecha_registro FROM bdmis:mi_solbanint WHERE fecha_registro = dFecha) THEN

        -- Se Inserta ala Tabla bdmis:mi_solbaninthist Valores de la Tabla bdmis:mi_solbanint

        --INSERT INTO bdmis:mi_solbaninthist(sucursal,clientesreg,totalclientesreg,id_status,fecha_registro)
        --SELECT sucursal,clientesreg,totalclientesreg,id_status,fecha_registro FROM bdmis:mi_solbanint;

        -- Se Borran Valores de la Tabla bdmis:mi_solbanint

        --DELETE FROM bdmis:mi_solbanint;

        -- Contabilizar status
		INSERT INTO bdmis:mi_solbaninthist(sucursal,id_status,totalclientesreg,fecha_registro,clientesreg)        
		select suc_registro,id_status,nvl(COUNT (numcte),0)as cte_tot,dFecha,
		nvl(sum (case when f_registro = dFecha then 1 end),0)  as cte_nvo
		FROM bdinteg:si_bpiusuarios
        where f_registro <= dFecha2 
		GROUP BY suc_registro,id_status;
        
    ELSE

        LET P_COD_RET = '000-1';
        LET P_MENSAJE = 'ESTA FECHA YA FUE PROCESADA';

    END IF;

    -- Variables de Retorno
 RETURN P_COD_RET,P_MENSAJE;

END
END PROCEDURE;