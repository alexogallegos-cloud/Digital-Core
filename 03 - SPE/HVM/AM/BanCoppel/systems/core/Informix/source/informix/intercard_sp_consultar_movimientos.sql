CREATE PROCEDURE "informix".sp_consultar_movimientos (
            pTipoTrxs CHAR(1),
            pInicioSemana DATETIME YEAR TO FRACTION(5),
            pFinalSemana DATETIME YEAR TO FRACTION(5),
            pFechaHoy DATE
    )
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;	
    
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);    
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);
	DEFINE RUTA_DESTINO VARCHAR(50);	
    DEFINE NOMBRE_ARCHIVO VARCHAR(50);
    DEFINE SCRIPT_EJECUCION VARCHAR(30);
    DEFINE TRANSACCIONES_AUTORIZADAS CHAR(1);
    DEFINE TRANSACCIONES_NO_AUTORIZADAS CHAR(1);    
    DEFINE vExecuteSQL LVARCHAR(4000);
    DEFINE vCondicionAdicional CHAR(50);
    DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);    
    DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);    
    DEFINE vMesAnyo CHAR(6);
    
    DEFINE vPrimerDiaMesHora DATETIME YEAR TO FRACTION(5);
    DEFINE vUltimoDiaMesHora DATETIME YEAR TO FRACTION(5);
    
    DEFINE vPrimerDiaSem VARCHAR(2);
    DEFINE vFinalDiaSem VARCHAR(2);
    
    LET vPrimerDiaMesHora = pInicioSemana;
    LET vUltimoDiaMesHora = pFinalSemana;
    
    LET vPrimerDiaSem = '00';
    LET vFinalDiaSem = '00';
    
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'Ejecucion exitosa.';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET TRANSACCIONES_AUTORIZADAS = 'A';
    LET TRANSACCIONES_NO_AUTORIZADAS = 'X';
    LET SCRIPT_EJECUCION = '';
    LET vCondicionAdicional = '';
    LET vExecuteSQL = '';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_consultar_movimientos.out";
    --TRACE ON;        
	
    BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_consultar_movimientos.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        


        IF ( pTipoTrxs = TRANSACCIONES_AUTORIZADAS ) THEN
            LET vCondicionAdicional = '  AND codigoiso = ''"'||'00'||'"'' ';
            LET NOMBRE_ARCHIVO = 'transacciones_autorizadas_';
            LET SCRIPT_EJECUCION = 'script_trxs_auto.sql';
        ELIF ( pTipoTrxs = TRANSACCIONES_NO_AUTORIZADAS ) THEN
            LET vCondicionAdicional = '  AND codigoiso <> ''"'||'00'||'"'' ';  
            LET NOMBRE_ARCHIVO = 'transacciones_no_autorizadas_';
            LET SCRIPT_EJECUCION = 'script_trxs_no_auto.sql';
        END IF
        
        LET vPrimerDiaSem = LPAD(DAY(vPrimerDiaMesHora), 2, '0');
        LET vFinalDiaSem = LPAD(DAY(vUltimoDiaMesHora),2,'0');            
        LET vMesAnyo = LPAD(MONTH(pFechaHoy),2,'0')||YEAR(pFechaHoy);
        
        LET primer_dia_mes_hora = pInicioSemana;
        LET ultimo_dia_mes_hora = pFinalSemana;
        
        LET NOMBRE_ARCHIVO = NOMBRE_ARCHIVO||vPrimerDiaSem||'_'||vFinalDiaSem||'_'||vMesAnyo;

        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO '||RUTA_ORIGEN||NOMBRE_ARCHIVO||'.txt'||
            ' SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,' ||
            '       codtran, fechaexptarj, codreversa, referencia, '||
            '  CASE WHEN (formato = ''"'||'0420' ||'"'' '||
            '     AND codreversa = ''"'|| '2' ||'"'') THEN '||
            '       (montorealrevfzda + montocashback) '||
            '       WHEN (formato <> ''"'||'0420' ||'"'' '||
            'AND codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
            'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
            'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
            'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
            'idretailer, secuenciaextendida '||
            'FROM intercard:movimiento '||
            'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
                'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
                'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
                'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
                'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
                'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
                'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
                'AND movreversado = ''"'||'F'||'"'' '||                                                 
                'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||vCondicionAdicional||
                
            'UNION ALL '||

                'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
            'codtran, fechaexptarj, codreversa, referencia, '||
            'case when (formato = ''"'||'0420' ||'"'' '||
            'and codreversa = ''"'||'2' ||'"'') then '||
            '(montorealrevfzda + montocashback) '||
            'when (formato <> ''"'||'0420' ||'"'' '||
            'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
            'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
            'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
            'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
            'idretailer, secuenciaextendida '||
            'FROM intercard:movimientohistorico '||
            'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
                'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
                'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
                'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
                'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
                'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
                'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
                'AND movreversado = ''"'||'F'||'"'' '||                                                 
                'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||vCondicionAdicional||                
                
                '" >'||RUTA_ORIGEN||SCRIPT_EJECUCION;
                
            SYSTEM vExecuteSQL;
            
           
        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'rm -f '||RUTA_ORIGEN||NOMBRE_ARCHIVO||'.txt.gz';
        SYSTEM vExecuteSQL;      
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   =	'rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL; 
        
        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'gzip -9 '||RUTA_ORIGEN||NOMBRE_ARCHIVO||'.txt';
        SYSTEM vExecuteSQL;                            

		RETURN CODIGO_RETORNO, MENSAJE_RETORNO;

	END
END PROCEDURE

---Obtiene los movimientos de las transacciones autorizadas y no autorizadas
---de acuerdo al parametro recibido pTipoTrxs: A = autorizadas | X = no autorizadas
---Base de datos: intercard
---Fecha de creacion: 02 de abril del 2019

;

CREATE PROCEDURE "informix".sp_actualizar_tarjetas()
    
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;
	
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);    
    DEFINE PREFIJO_SCRIPTS CHAR(10);
    DEFINE vCadenaTmp CHAR(50);
    DEFINE vUserInsert VARCHAR(100);
    DEFINE cPlazoSMS_Inv CHAR(20);
    DEFINE cPlazoSMS CHAR(20);
	
    DEFINE vFechaHoy DATE;
    DEFINE vFechaServidor DATE;
    DEFINE vFechaEjecucion DATE;
    DEFINE vTrxsAcumuladas INTEGER;
    DEFINE vExisteRegistro SMALLINT;
    
    DEFINE vFechaInAuth DATE;
    DEFINE vTipoTrx CHAR(2);
    
    DEFINE vNumLote CHAR(8);
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET PREFIJO_SCRIPTS = 'trx_monit_';	
    LET RUTA_ORIGEN = '/ifxsif01/_argoz/lecciones/';
	
    LET vUserInsert	= '';	
	LET vCadenaTmp = '';	
	LET cPlazoSMS_Inv = '18, 12, 06';	
	LET cPlazoSMS = '';	

    LET vFechaHoy = '';
    LET vFechaServidor = '';
    LET vFechaEjecucion = '';	
    LET vTrxsAcumuladas = 0;	
    LET vExisteRegistro = 0;	
    
    

    ------------------
    LET vFechaInAuth = '';
    LET vTipoTrx = '';
    LET vNumLote = '';

    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_actualizar_tarjetas.out";
    --TRACE ON;        
	
    BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
            
        drop table if exists tmp_numeros_lote;
        SELECT numerolote 
            FROM intercard:flujolote
        WHERE fecha >= '2019-01-01 00:00:00' AND fecha <= '2019-04-25 00:00:00' 
        and codflujo = 'RES'
        INTO TEMP tmp_numeros_lote WITH NO LOG; ----Lotes recibidos: 2, 287


        FOREACH cursor1 WITH HOLD FOR
            
            SELECT numerolote 
                INTO vNumLote 
                FROM tmp_numeros_lote
            BEGIN;
                update "informix".tarjeta
                set codstatusasignada = 'NOA'
                where numerolote = vNumLote
                and  codstatusasignada = 'NOE';
            COMMIT;
                
        END FOREACH;
    
  
    
		RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
		
	END
END PROCEDURE
;