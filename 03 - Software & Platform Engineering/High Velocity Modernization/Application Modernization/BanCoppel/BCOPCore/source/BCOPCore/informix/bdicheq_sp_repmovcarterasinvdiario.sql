CREATE PROCEDURE "informix".sp_repmovcarterasinvdiario()
    
    RETURNING CHAR(5);

    DEFINE cNumcte      CHAR(20);
    DEFINE cTarjeta     CHAR(20);
    DEFINE cSuc         CHAR(4);
    DEFINE cTransacc    CHAR(4);
    DEFINE cProd        CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE dFecha       DATE;
    DEFINE dtHora       DATETIME HOUR TO FRACTION(3);
    DEFINE mMonto       MONEY;
    DEFINE p_cod_ret    VARCHAR(5);
    DEFINE error_info   VARCHAR(80);
    DEFINE p_mensaje    VARCHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE nComit       INTEGER;
    DEFINE nCont        INTEGER;
    DEFINE nCont2       INTEGER;
    DEFINE dfecha_hoy   DATE;
    DEFINE cFechaNomArc CHAR(10);
    DEFINE cAnio        CHAR(4);
    DEFINE cMes         CHAR(2);
    DEFINE cDia         CHAR(2);
    DEFINE cNom         CHAR(40);
    DEFINE vSql         CHAR(600);
    DEFINE cStatus_tar  CHAR(3);
    DEFINE dFecha_ant   DATE;
    DEFINE cValorIP     CHAR(20);
    DEFINE vmaxcta      CHAR(20);
    DEFINE vmincta      CHAR(20);

    BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
    LET p_cod_ret = sql_err;
    LET p_mensaje = error_info;
    IF nComit = 1 THEN
    ROLLBACK WORK;
    END IF;
    RETURN p_cod_ret;
    END EXCEPTION;

    -- Set debug file To '/tmp/sp_repmovcarterasinvdiario.out';
    -- Trace On;

    LET cNumcte = '';
    LET cTarjeta = '';
    LET cSuc = '';
    LET cTransacc = '';
    LET cProd = '';
    LET cCuenta = '';
    LET dFecha = '';
    LET dtHora = '';
    LET mMonto = '0';
    LET p_cod_ret = '00000';
    LET sql_err = '0';
    LET isam_err = '0';
    LET error_info = '';
    LET p_mensaje = '';
    LET nComit = 0;
    LET nCont = 0;
    LET nCont2 = 0;
    LET dfecha_hoy = '';
    LET cFechaNomArc = '';
    LET cAnio = '';
    LET cMes = '';
    LET cDia = '';
    LET cNom = '';
    LET vSql = '';
    LET dFecha_ant  = '';
    LET cValorIP = '';

    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;

    BEGIN WORK;
    LET nComit = 1;

    SELECT fecha_hoy
      INTO dfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    -- // Selecciona la fecha de ultima ejecucion del proceso
    SELECT max(fecha_ejecucion) 
      INTO dFecha_ant
      FROM bdicheq:sc_ctrrepcarteras
     WHERE proceso = 'sp_RepMovCarterasInvDiario';

    IF dFecha_ant = dfecha_hoy THEN
        LET p_cod_ret = 100;  --Ya se ejecuto proceso en mismo dia
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    -- // Reguistra la fecha de ultima ejecucion en tabla de control de procesos
    INSERT INTO bdicheq:sc_ctrrepcarteras (proceso,fecha_ejecucion)
    VALUES('sp_RepMovCarterasInvDiario',dfecha_hoy);
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM bdinvers:sv_movhis;

    FOREACH with hold
        SELECT '', nvl(mov.sucursal, ''), mov.transacc, mov.cod_instrum, 
               mov.cuenta, mov.fech_alt, mov.fech_hor, mov.monto_tot
          INTO cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto
          FROM bdinvers:sv_movhis mov        
         WHERE mov.empresa = '001'
           AND mov.cuenta BETWEEN vmincta AND vmaxcta
           AND mov.fech_alt >= dFecha_ant 
           AND mov.fech_alt < dfecha_hoy

        SELECT limit 1 trim(nvl(num_cte, '')) 
          INTO cNumcte
          FROM bdinvers:sv_maeinv
         WHERE empresa = '001' 
           AND cuenta = cCuenta;

        INSERT INTO bdicheq:sc_repmovcarterasdiario (num_cte,num_tarjeta,sucursal,transaccion,producto,cuenta,fecha_mov,hora_mov,monto_mov)
        VALUES(cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto);

        LET nCont = nCont + 1;
        LET nCont2 = nCont2 + 1;

        -- // Realiza comint cada 5000 registros
        IF nComit = 1 AND nCont = 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET nComit = 1;
            LET nCont = 0;
        END IF;
        
        -- // Realiza un statistics cada 50000 registros 
        IF nCont2 = 50000 THEN
            UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;
            LET nCont2 = 0;
        END IF;
    END FOREACH;

    COMMIT WORK;
    LET nComit = 0;    

    RETURN p_cod_ret;

    END;

END PROCEDURE
DOCUMENT
    'DESCRIPCION: Programa que se encarga de generar el reporte de movimientos diarios de Inversiones para carteras',
    'se creo la tabla bdicheq:sc_RepMovCarterasDiario, que es la tabla que se llenara para tomar los datos para generar el archivo',
    'AUTOR: Armando Mercado',
    'FECHA: Enero/2009',
    'BD: Bdicheq',
    'REGISTROS X MINUTO: 19,800 En ambiente de desarrollo';

create procedure "informix".cal_fecharet( pfechaofi  date )
    RETURNING char(5), date;  

    DEFINE v_codret         char(5);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;  
    DEFINE v_fechapre       date;
    DEFINE v_esferiadox     char(1); 

    LET v_codret = "000";
    LET v_fechapre = " ";

    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret,v_fechapre;
        end if;
    end exception;

    -- set debug file to "cal_fecharet.txt";
    -- trace on;
    
    set isolation to dirty read;

    -- // Valida la informacion de entrada
    IF pfechaofi is null THEN
        -- // Datos de entrada incompletos
        LET v_codret = 210; 
        RETURN v_codret, v_fechapre; 
    END IF;

    -- // Validar feriado, sab o dom
    select "1"
      into v_esferiadox
      from bdinteg:si_feriado
     where fecha = pfechaofi;

    IF v_esferiadox is null THEN
        LET v_esferiadox = "0";
    END IF

    -- // Cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
    IF v_esferiadox = "1" or 
       to_char(pfechaofi, "%A") = "Saturday" or 
       to_char(pfechaofi, "%A") = "Sunday" THEN 
        -- // Calcular la fecha correcta
        
        call cal_fecha_pre_fh(pfechaofi)
        returning v_codret, v_fechapre;	
        
        RETURN v_codret, v_fechapre;
    END IF

    LET v_fechapre = pfechaofi;	

    END;    

    RETURN v_codret,v_fechapre;

END PROCEDURE;