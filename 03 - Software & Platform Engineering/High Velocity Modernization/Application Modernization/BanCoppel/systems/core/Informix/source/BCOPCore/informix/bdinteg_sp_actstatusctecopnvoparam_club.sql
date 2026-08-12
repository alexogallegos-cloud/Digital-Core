CREATE PROCEDURE "informix".sp_actstatusctecopnvoparam_club()

	RETURNING
		CHAR(5);

	--- DECLARACIONES
	DEFINE cCodRet 							CHAR(5);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cnumcte_coppel                   CHAR(20);
	DEFINE ctrama 							LVARCHAR(10000);	
	DEFINE vsRepositorio  					CHAR(200);
    DEFINE vsNomArchivo 					CHAR (50);
    DEFINE vsNomArchivoF 					CHAR (50);
	DEFINE cNombre							CHAR (50);
    DEFINE vsSQL 							CHAR (1050) ;
    DEFINE vsSQL1 							CHAR (150);
    DEFINE vsSQL2 							CHAR (750) ;
    DEFINE vsSQL3 							CHAR (150) ;
    DEFINE vsFlagSystem 					CHAR (1);
	DEFINE cHora							CHAR (2);
	DEFINE cMin								CHAR (2);
	DEFINE csec								CHAR (2);
	DEFINE dhoraActual 						CHAR (8);	
	
	--- INICIALIZACIONES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cnumcte_coppel = '';
	LET ctrama = '';
	LET vsRepositorio = '';
	LET vsNomArchivo = '';
	LET vsNomArchivoF = '';	
	LET cNombre ='';
    LET vsSQL = '' ;
    LET vsSQL1 = '' ;
    LET vsSQL2 = '' ;
    LET vsSQL3 = '' ;
    LET vsFlagSystem = '';	
	LET cHora = '';	
	LET cMin = '';	
	LET csec = '';	
	LET dhoraActual = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

    BEGIN

    ON EXCEPTION SET iSqlErr    --cacha el error en caso de que exista y regresa un valor predeterminado
        -- ELIMINA LA TABLA TEMPORAL DE REPORTE
        SET ISOLATION TO DIRTY READ;
        IF EXISTS ( SELECT dbsname, tabname 
                      FROM sysmaster:SysTabNames  
                     WHERE partnum > 0 
                       and tabname = 'tmpxmlarchclientecoppel' 
                       AND dbsname= 'bdinteg') THEN
            DROP TABLE BdInteg:tmpxmlarchclientecoppel;
        END IF;

        LET cCodRet = iSqlErr;

        IF (vsFlagSystem = '1') THEN -- ERROR DE GENERACION DEL ARCHIVO
            LET cCodRet = '00001';
        END IF;

        RETURN cCodRet ;
    END EXCEPTION;		
	
	--SET DEBUG FILE TO '/informix/ifxsif01/Control-M/sp_actstatusctecopnvoparam_club.out';
	--TRACE ON;
	
	--LET vsRepositorio = "/RESPALDOSNEW/CTECOPPEL";
	
	-- // VALIDA SI EXISTE LA TABLA DEL REPORTE
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname 
				  FROM sysmaster:SysTabNames  
				 WHERE partnum > 0
				   and tabname = 'tmpxmlarchclientecoppel' 
				   AND dbsname= 'bdinteg') THEN
		DROP TABLE Bdinteg:tmpxmlarchclientecoppel;
	END IF;

	-- // CREA LA TABLA DEL REPORTE
	CREATE TABLE tmpxmlarchclientecoppel
	(
		numcte_coppel  CHAR(20) NOT NULL,
		XML            LVARCHAR(10000)
	);
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD 		
		SELECT numcte_coppel, XML 
		INTO cnumcte_coppel, ctrama
		FROM clientes_coppel_envia_xml
		WHERE enviado ='0'
					
		
		UPDATE clientes_coppel_envia_xml SET enviado= '1' WHERE numcte_coppel= cnumcte_coppel;
		
		INSERT INTO tmpxmlarchclientecoppel(numcte_coppel, XML)
		VALUES (cnumcte_coppel, ctrama);
		
	END FOREACH;
	
	SELECT TRIM(valor)
	INTO vsRepositorio
	FROM bdinteg:"informix".si_param
	WHERE cod_param='529';
	
	SELECT TRIM(valor)
	INTO cNombre
	FROM bdinteg:"informix".si_param
	WHERE cod_param='530';
	
	SELECT DBINFO("utc_to_datetime", sh_curtime)::DATETIME HOUR TO SECOND 
	INTO dhoraActual
	FROM sysmaster:sysshmvals;
	
	LET cHora = substr(dhoraActual,1,2);
	LET cMin  = substr(dhoraActual,4,2);
	LET csec  = substr(dhoraActual,7,2);
	   
   -- // GENERA EL NOMBRE DEL ARCHIVO DE INTERCAMBIO nomenclatura:  ArchivoCombinado__AAAA-MM-DD_HH-MM-SS.log
	LET vsNomArchivo = TRIM(cNombre) || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '.log';
	LET vsNomArchivoF = TRIM(cNombre) || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '_' ||cHora || '-' || cMin || '-' ||csec ||'.log';
	
	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo) || ' DELIMITER ' || '''|''';
	LET vsSQL2 = "SELECT numcte_coppel, sp_remplaza_n(XML) FROM BdInteg:tmpxmlarchclientecoppel;" ;
	LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/clientes_coppelxml.sql';

	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

	-- // CHECA QUE NO ESTE VACIA LA CONSULTA
	IF ( vsSQL <> '' ) THEN
		LET vsFlagSystem = '1';

		-- // CREA ARCHIVO DE CONTROL
		SYSTEM vsSQL ;

		let vsSQL = '' ;
		LET vsSQL = 'dbaccess Bdinteg ' || TRIM(vsRepositorio) || '/clientes_coppelxml.sql' ;
		SYSTEM vsSQL ;

		LET vsSQL = "sed 's/|$//g' "|| TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo) || " > " || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivoF);
		SYSTEM vsSQL;

		LET vsSQL = 'rm ' || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo)  ;
		SYSTEM vsSQL ;
		
		-- // BORRA EL ARCHIVO DE CONTROL
		let vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/clientes_coppelxml.sql' ;
		SYSTEM vsSQL ;

		LET vsFlagSystem = '';
	ELSE 
        -- // CONSULTA VACIA
        LET cCodRet = '00002';		
	END IF;		
	
	-- // ELIMINA LA TABLA TEMPORAL DE REPORTE
	DROP TABLE BdInteg:tmpxmlarchclientecoppel;

	RETURN  cCodRet; 

	END;
END PROCEDURE
DOCUMENT
'Autor: 		Maria Elena Angulo',
'Fecha: 		30/04/2024',
'Descripcion:	Proceso para actualizar el estatus para validar si ya se envió a coppel',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_consultainforoi(
pNumeroCliente               CHAR(9),   --Es el nÃºmero del cliente que realiza la operaciÃ³n inusual
pNumeroCuenta                CHAR(11),  --Es el nÃºmero de cuenta del cliente que realiza la operaciÃ³n inusual
pNumeroTarjeta               CHAR(16),  --NÃºmero de tarjeta del cliente que realiza la operaciÃ³n inusual
pNumeroUsuario               CHAR(9),  --El nÃºmero de usuario a reportar (El cual es el nÃºmero de cliente)
pNumeroColaborador           CHAR(8),   --Es el nÃºmero del colaborador involucrado en la operaciÃ³n inusual
pOrdenPago                   CHAR(12),  --Es el nÃºmero de orden de pago con el cual se va a solicitar la informaciÃ³n del usuario
pNumeroRemesa                CHAR(12),  --Es el nÃºmero de remesa con el cual se va a solicitar la informaciÃ³n del usuario
pGenerico1                   CHAR(100), --Parametro generico que recibe 100 caracteres
pGenerico2                   CHAR(200), --Parametro generico que recibe 200 caracteres
pGenerico3                   CHAR(300)) --Parametro generico que recibe 300 caracteres

RETURNING
--Datos a retornar
CHAR(5)          AS   cCodRet,                  --Codigo de retorno del SP
CHAR(80)         AS   cDescripcionCodRetorno,   --Descripcion del codigo retorno
CHAR(40)         AS   cNombre1,                 --El primer nombre del cliente o del usuario a reportar
CHAR(40)         AS   cNombre2,                 --El Segundo nombre del cliente o del usuario a reportar
CHAR(40)         AS   cApellidoPaterno,         --El apellido paterno del cliente o usuario a reportar
CHAR(40)         AS   cApellidoMaterno,         --El apellido materno del cliente o usuario a reportar
CHAR(9)          AS   cNumeroCliente,           --El nÃºmero de cliente de la persona que se va a reportar
CHAR(20)         AS   cCuentaCliente,           --Es la cuena del cliente a reportar
CHAR(16)         AS   cNumeroTarjeta,           --Es el nÃºmero de Tarjeta del cliente a reportar
CHAR(20)         AS   cPuestoColaborador,       --Es el nombramiento del colaborador
CHAR(20)         AS   cNombreGerente,           --Es el nombre del gerente que realizo la operaciÃ³n inusual
CHAR(100)        AS   cGenerico1,               --Texto generico 1 para el mensaje (opcional)
CHAR(100)        AS   cGenerico2,               --Texto generico 2 para el mensaje (opcional)
CHAR(100)        AS   cGenerico3;               --Texto generico 3 para el mensaje (opcional)

--Definicion de las variables sp_consultaClienteRoi

DEFINE iSqlErr                  INTEGER;    --Error SQL
DEFINE cCodRet                  CHAR(5);
DEFINE cDescripcionCodRetorno   CHAR(80);   
DEFINE cNombre1                 CHAR(40);                
DEFINE cNombre2                 CHAR(40);
DEFINE cApellidoPaterno         CHAR(40);
DEFINE cApellidoMaterno         CHAR(40);
DEFINE cNumeroCliente           CHAR(20);   
DEFINE cCuentaCliente           CHAR(20);
DEFINE cNumeroTarjeta           CHAR(16);
DEFINE cPuestoColaborador       CHAR(20);
DEFINE cNombreGerente           CHAR(20);
DEFINE cGenerico1               CHAR(100);
DEFINE cGenerico2               CHAR(100);
DEFINE cGenerico3               CHAR(100);

DEFINE iContadorAuxiliar        INTEGER;

--Inicializacion de variables
LET iSqlErr                     = 0;					--- Error SQL
LET cDescripcionCodRetorno      = 'Se encontro con exito la informacion solicitada'; --- Descripcion del estado de la transaccion
LET cCodRet                     = '00000';              --- Codigo de retorno de la transaccion
LET cNombre1                    = '';
LET cNombre2                    = '';
LET cApellidoPaterno            = '';
LET cApellidoMaterno            = '';
LET cNumeroCliente              = '';
LET cCuentaCliente              = '';
LET cNumeroTarjeta              = '';
LET cPuestoColaborador          = '';
LET cNombreGerente              = '';
LET cGenerico1                  = '';
LET cGenerico2                  = '';
LET cGenerico3                  = '';
LET iContadorAuxiliar           = 0;

BEGIN
    -- Control de errores 'informix', excepciones no controladas
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN  cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/home/c90314234/bdinteg/sp_consultainforoi.out";	
--   SET DEBUG FILE TO "/home/systelmex/pruebasroi/sp_consultainforoi.out";
--	TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --Valida que se haya ingresado los paramaetros correpondientes
    IF pNumeroRemesa = '' AND pOrdenPago = '' AND pNumeroUsuario = '' AND pNumeroColaborador = '' AND
    pNumeroTarjeta = '' AND pNumeroCuenta = '' AND pNumeroCliente = '' THEN
        LET cCodRet = '00500';
        LET cDescripcionCodRetorno = 'No se ha ingresado informacion. Por favor, valide los datos.';
        RETURN cCodRet, cDescripcionCodRetorno, cNombre1, cNombre2, cApellidoPaterno,
        cApellidoMaterno, cNumeroCliente, cCuentaCliente, cNumeroTarjeta, cPuestoColaborador, cNombreGerente,
      cGenerico1, cGenerico2, cGenerico3;
    END IF;
    --Consulta campos ingresados
    --Se consulta si tiene numero de remesa
    IF pNumeroRemesa != '' THEN
        --Se valida si la longitud es correcta
        IF LENGTH(pNumeroRemesa) != 10 AND LENGTH(pNumeroRemesa) != 11 AND LENGTH(pNumeroRemesa) != 12  THEN
            LET cDescripcionCodRetorno = 'La longitud de la remesa no es de 10,11 u 12 caracteres, favor de validar';
            LET cCodRet = '00200';
        
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
        --Consulta informaciÃ³n por nÃºmero de remesa
        --Se valida que exita la referencia
        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdisac:"informix".sac_remesas_estadistica 
        WHERE referencia = pNumeroRemesa;
        -- si existe la referencia se llenan los datos correspondientes
        IF iContadorAuxiliar > 0 THEN    
            SELECT nombre1,nombre2,appaterno,apmaterno
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdisac:"informix".sac_remesas_estadistica
            WHERE referencia = pNumeroRemesa;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdisac:"informix".sac_remesas_estadistica_old
            WHERE referencia = pNumeroRemesa;
            IF iContadorAuxiliar > 0 THEN
                SELECT nombre1,nombre2,appaterno,apmaterno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdisac:"informix".sac_remesas_estadistica_old
                WHERE referencia = pNumeroRemesa;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro la remesa, por favor revise la informacion solicitada.';
                LET cCodRet = '00110'; 
            END IF;
        END IF;

        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
        --Consulta informaciÃ³n por Orden de pago
    IF pOrdenPago != '' THEN
        IF LENGTH(pOrdenPago) != 12 THEN
            LET cDescripcionCodRetorno = 'La longitud de la orden de pago no es de 12 caracteres, favor de validar';
            LET cCodRet = '00210';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdisac:"informix".sac_enviosdineroya
        WHERE no_control = pOrdenPago;

        IF iContadorAuxiliar>0 THEN
            SELECT pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdisac:"informix".sac_enviosdineroya
            WHERE no_control = pOrdenPago;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdisac:"informix".sac_enviosdineroyahis
            WHERE no_control = pOrdenPago;

            IF iContadorAuxiliar>0 THEN
                SELECT pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdisac:"informix".sac_enviosdineroyahis
                WHERE no_control = pOrdenPago;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro la Orden de pago, verifique la Orden de pago.';
                LET cCodRet = '00120';
            END IF;
        END IF; 
        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
    -- Consulta usuario por el numero de usuario (El numero de usuario es el nÃºmero de cliente)
    IF pNumeroUsuario != '' THEN
        IF LENGTH(pNumeroUsuario) != 9 THEN
                LET cDescripcionCodRetorno = 'La longitud del numero de usuario no es de 9 caracteres, favor de validar';
                LET cCodRet = '00260';
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
        END IF;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdinteg:"informix".si_cliente 
        WHERE numcte = pNumeroUsuario;
        
        IF iContadorAuxiliar > 0 THEN         
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = pNumeroUsuario;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:"informix".SI_FUSCLIENTE 
            WHERE numcte = pNumeroUsuario;

            IF iContadorAuxiliar > 0 THEN
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE numcte = pNumeroUsuario;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro el usuario, verifique el numero de usuario.';
                LET cCodRet = '00130';
            END IF;
        END IF;      
        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
    --Consultar por el nÃºmero de colaborador
    IF pNumeroColaborador != '' THEN

    END IF;
    --Consulta informaciÃ³n por nÃºmero de tarjeta
    IF pNumeroTarjeta != '' THEN
        IF LENGTH(pNumeroTarjeta) != 16 THEN
            LET cDescripcionCodRetorno = 'La longitud del numero de tarjeta no es de 16 caracteres, favor de validar.';
            LET cCodRet = '00230';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;        
        SELECT COUNT(*)
        INTO iContadorAuxiliar 
        FROM bdicheq:"informix".sc_tarjeta 
        WHERE num_tarjeta = pNumeroTarjeta;

        IF iContadorAuxiliar > 0 THEN
            SELECT numcte,cuenta
            INTO  cNumeroCliente,cCuentaCliente
            FROM bdicheq:"informix".sc_tarjeta 
            WHERE num_tarjeta = pNumeroTarjeta;
            
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = cNumeroCliente;

            IF iContadorAuxiliar > 0 THEN 
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = cNumeroCliente;
            ELSE
                SELECT COUNT(*)
                INTO iContadorAuxiliar
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE numcte = cNumeroCliente;
                
                IF iContadorAuxiliar > 0 THEN 
                    SELECT nombre1,nombre2,apell_paterno,apell_materno
                    INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                    FROM BDINTEG:"informix".SI_FUSCLIENTE  
                    WHERE numcte = cNumeroCliente;
                ELSE
                    LET cDescripcionCodRetorno = 'No se encontro al cliente solicitado, verifique el numero de cliente.';
                    LET cCodRet = '00100';
                END IF;
            END IF;      
        ELSE
            LET cDescripcionCodRetorno = 'No se encontro la tarjeta, verifique el numero de tarjeta.';
            LET cCodRet = '00140';
        END IF;  
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,pNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
    END IF;
    IF pNumeroCuenta != '' THEN
        IF LENGTH(pNumeroCuenta) != 11 THEN
            LET cDescripcionCodRetorno = 'La longitud del numero de cuenta no es de 11 caracteres, favor de validar';
            LET cCodRet = '00240';
        
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
        LET cCuentaCliente= pNumeroCuenta;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM BDICHEQ:"informix".SC_MAECHQ
        WHERE CUENTA = pNumeroCuenta;

        IF iContadorAuxiliar > 0 THEN
            SELECT num_cte
            INTO cNumeroCliente
            FROM BDICHEQ:"informix".SC_MAECHQ
            WHERE CUENTA = pNumeroCuenta;

             --REGRESA NOMBRES Y APELLIDOS DEL CLIENTE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:SI_CLIENTE 
            WHERE NUMCTE = cNumeroCliente;

            IF iContadorAuxiliar > 0 THEN
                --REGRESA NOMBRES Y APELLIDOS DEL CLIENTE
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno 
                FROM BDINTEG:SI_CLIENTE 
                WHERE NUMCTE = cNumeroCliente;
            ELSE
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno 
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE NUMCTE = cNumeroCliente;       
            END IF;
			
			SELECT COUNT(*)
			INTO iContadorAuxiliar
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE cuenta = pNumeroCuenta;
			
			IF iContadorAuxiliar != 0 THEN
			
				--Foreach que recorre las filas de las consultas
				FOREACH iteracionTarjeta FOR
					SELECT num_tarjeta
					INTO cNumeroTarjeta
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE cuenta = pNumeroCuenta

					RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
					cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
					cGenerico1,cGenerico2,cGenerico3 WITH RESUME;   
                                                               
				END FOREACH;
			
			ELSE
				RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
					cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
					cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
			END IF
			
        ELSE
            LET cDescripcionCodRetorno = 'No se encontro el numero de cuenta, verifique el numero de cuenta.';
            LET cCodRet = '00150';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
    END IF;
        
    IF pNumeroCliente != '' THEN
        --VERIFICA SI EXISTE EL CLIENTE
        IF LENGTH(pNumeroCliente) != 9 THEN
            LET cDescripcionCodRetorno = 'La longitud del nÃºmero de cliente no es de 9 caracteres, favor de validar';
            LET cCodRet = '00250';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
       
        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdinteg:"informix".si_cliente 
        WHERE numcte = pNumeroCliente;

        IF iContadorAuxiliar > 0 THEN
            --Nombres y apellidos
            SELECT nombre1,nombre2,apell_paterno,apell_materno
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = pNumeroCliente;
            -- numero de cliente
            LET cNumeroCliente = pNumeroCliente;

            SELECT COUNT(Cuenta)
            INTO cCuentaCliente
            FROM BDICHEQ:"informix".SC_MAECHQ 
            WHERE num_cte = pNumeroCliente;
            --VALIDA SI TIENE CUENTAS
            IF iContadorAuxiliar > 0 THEN
            -- numero de cuenta
                FOREACH iteracionCuenta FOR
                    SELECT cuenta
                    INTO cCuentaCliente
                    FROM BDICHEQ:"informix".SC_MAECHQ 
                    WHERE num_cte = pNumeroCliente
                    --numero de tarjeta
                    LET cNumeroTarjeta = '';
                    IF EXISTS (SELECT 1 FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = cCuentaCliente) THEN
                        FOREACH iteracionTarjeta FOR
                            SELECT num_tarjeta
                            INTO cNumeroTarjeta
                            FROM bdicheq:"informix".sc_tarjeta 
                            WHERE cuenta = cCuentaCliente

                            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                            cGenerico1,cGenerico2,cGenerico3 WITH RESUME;   
                                                                
                        END FOREACH;
                    ELSE 
                        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                        cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
                    END IF;
                END FOREACH;
            ELSE
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
            END IF;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:SI_FUSCLIENTE
            WHERE numcte = pNumeroCliente;
                    
            IF iContadorAuxiliar > 0 THEN
                --Nombres y apellidos
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_fuscliente 
                WHERE numcte = pNumeroCliente;
                -- numero de cliente
                LET cNumeroCliente = pNumeroCliente;
                -- numero de cuenta
                FOREACH iteracionCuenta FOR
                    SELECT cuenta
                    INTO cCuentaCliente
                    FROM BDICHEQ:"informix".SC_MAECHQ 
                    WHERE num_cte = pNumeroCliente
                    --numero de tarjeta
                    LET cNumeroTarjeta = '';
                    IF EXISTS (SELECT 1 FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = cCuentaCliente) THEN
                        FOREACH iteracionTarjeta FOR
                            SELECT num_tarjeta
                            INTO cNumeroTarjeta
                            FROM bdicheq:"informix".sc_tarjeta 
                            WHERE cuenta = cCuentaCliente

                            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                            cGenerico1,cGenerico2,cGenerico3 WITH RESUME;                                           
                        END FOREACH;
                    ELSE 
                        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                        cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
                    END IF;
                END FOREACH;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro al cliente solicitado,favor de verificar los datos';
                LET cCodRet = '00100';
                  
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
            END IF;
        END IF;
    END IF;

END;
END PROCEDURE

DOCUMENT 'AUTOR: Osiel  Alfredo Camacho Mendoza',
'FECHA 29/12/2023',
'MODULO: Mejoras 11 183 Mejoras ROI ',
'FUNCIONALIDAD: Consulta usuario ROI',
'DESCRIPCION: SPL encargado de devolver la informaciÃ³n del cliente/usuario/colaborador que realizo una operaciÃ³n inusual'
;

CREATE PROCEDURE "informix".sp_consultatickethuelladec_or()

--DATOS A REGRESAR---
RETURNING          
	CHAR(5)   			AS codigoretorno,
	CHAR(50)			AS ticket;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultatickethuelladec_or"
Folio.........: 841 - ComparaciÃÂ³n en linea de 10 huellas.
Autor.........: 90127902 - Carlos Vazquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE cTicket		CHAR(50);
DEFINE iContador	INTEGER;
DEFINE jContador	INTEGER;

 --SET DEBUG FILE TO '/informix/jfponce/gabriel/TRACE/sp_consultatickethuelladec_or.out';
 --TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet			= '00000';
LET iSqlErr			= 0;
LET cTicket			= '';	
LET iContador		= 0;
LET jcontador       = 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTicket;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte)
		INTO icontador
	FROM "informix".si_huella_linea_dec 
	WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') OR (status_consulta='1' AND fecha_result IS NULL));
	
	
	IF(iContador > 0) THEN
	
		FOREACH
			SELECT ticket 
				INTO cTicket 
			FROM "informix".si_huella_linea_dec 
			WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') 
			OR (status_consulta='1' AND fecha_result IS NULL))
			RETURN cCodRet, cTicket WITH RESUME;
		END FOREACH;
			
			SELECT COUNT(numcte)
			INTO jcontador
			FROM "informix".si_huella_linea_dec_hist 
			WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') OR (status_consulta='1' AND fecha_result IS NULL));
				
			
			IF(jContador > 0) THEN
				FOREACH
					SELECT ticket 
						INTO cTicket 
					FROM "informix".si_huella_linea_dec_hist 
					WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') 
					OR (status_consulta='1' AND fecha_result IS NULL))
					RETURN cCodRet, cTicket WITH RESUME;
				END FOREACH;
			END IF;
			
	ELSE			
		LET cCodRet = '00001';
		RETURN cCodRet, cTicket WITH RESUME;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'RQI 6310007 Se agrega validacion para consultar en la tabla historica el si_huella_linea_dec_hist ticket',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 15/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_generahuellalinea(
													pNumCte CHAR(20),
													pIP CHAR(15),
													pTipoMov CHAR(2),
													pEmpleado CHAR(8),
													pVerificacion CHAR(2),
													pSensor CHAR(2)
												)

--DATOS A REGRESAR---
RETURNING
CHAR(5) 					AS CodigoRetorno,
CHAR(2000) 					AS TramaSalida;


--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCadena				CHAR(2000);
DEFINE dFechaCons			DATETIME YEAR TO DAY;
DEFINE fechaComparacion		DATETIME YEAR TO DAY;
DEFINE cSecuencia			CHAR(2);
DEFINE cSexo				CHAR(1);
DEFINE cSucursal			CHAR(4);
DEFINE cFechAlta			CHAR(10);
DEFINE cHuellaD				CHAR(942);
DEFINE cHuellaI				CHAR(942);
DEFINE cStatuHuella 		CHAR(1);
DEFINE cRefCte				CHAR(20);
DEFINE dFechaUltCon			DATETIME YEAR TO SECOND;
DEFINE cTipoCte				CHAR(2);
DEFINE cTicket				CHAR(20);
DEFINE cStatusCons			CHAR(1);
DEFINE cRspMsj601			CHAR(1);
DEFINE cFechaAlt			CHAR(10);
DEFINE cFecUlCam			CHAR(18);
DEFINE cContador 			INTEGER;
DEFINE cContador_2 			INTEGER;
DEFINE cContador_3			INTEGER;
DEFINE cContador_4			INTEGER;
DEFINE cContador_5			CHAR(1);
DEFINE cContador_6			INTEGER;
DEFINE cSecuenciaMax 		INTEGER;
DEFINE cSecuenciaDec 		INTEGER;
DEFINE iHuellas_cap 		SMALLINT;
DEFINE dFecha_alta_prueba 	DATE;
DEFINE cprint				CHAR(50);
DEFINE iExiste				SMALLINT;
DEFINE iVacio				SMALLINT;

  --SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_PropuestaFinal.out";
  --TRACE ON;

--INICIALIZACION DE VARIABLES--
LET iSql_err 	 		= 0;
LET cCodRet 	 		= '00000';
LET cCadena		 		= "";
LET dFechaCons	 		= TODAY;
LET fechaComparacion	= TODAY;
LET cSecuencia	 		= "";
LET cSexo		 		= "";
LET cSucursal	 		= "";
LET cFechAlta	 		= "";
LET cHuellaD	 		= "";
LET cHuellaI	 		= "";
LET cStatuHuella 		= "";
LET cRefCte		 		= "";
LET dFechaUltCon 		= CURRENT YEAR TO SECOND;
LET cTipoCte	 		= "";
LET cTicket		 		= "";
LET cStatusCons  		= "0";
LET cRspMsj601   		= "";
LET cFechaAlt	 		= "";
LET cFecUlCam	 		= "";
LET cContador    		= 0;
LET cContador_2  		= 0;
LET cContador_3  		= 0;
LET cContador_4  		= 0;
LET cContador_5			= "0";
LET cContador_6			= 0;
LET cSecuenciaMax 		= 0;
LET cSecuenciaDec 		= 1;
LET iHuellas_cap 		= 0;
LET dFecha_alta_prueba 	= TODAY;
LET cprint				= '';
LET iExiste				= 0;
LET iVacio				= 0;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet, cCadena;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

	--Controlar tipo pTipoMov = 'A' y pTipoMov vacio
	IF (pTipoMov = 'A') THEN
		LET pTipoMov = '1';
	ELIF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL )	THEN
		LET pTipoMov = '1';
		LET iVacio = 1;
	END IF;
	
	SELECT COUNT(*) 
	INTO cContador
	FROM bdinteg:"informix".si_cliente 
	WHERE numcte = pNumCte;

	IF (cContador > 0) THEN		
		
		--Fecha Consulta
		SELECT fecha_hoy 
		INTO dFechaCons 
		FROM bdinteg:"informix".si_fechas 
		WHERE empresa = '001';
		
		--Nuevas lineas para comparar si fueron tomadas nuevas huellas. En caso de que si se pone cContador_5 = '1'
		SELECT MAX(fecha)
		INTO fechaComparacion
		FROM bdinteg:"informix".si_cte_huella_dec_actual
		WHERE numcte = pNumCte;

		SELECT COUNT(*) 
        INTO cContador_6
        FROM bdinteg:"informix".si_huella_linea_dec 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
	
		IF (fechaComparacion == dFechaCons )THEN
			LET cContador_5 = '1';
		END IF;
		
		
		
		--Se consulta la huella del cliente si no existen o es de otro dia la consulta se agregan
		SELECT COUNT(*) 
		INTO cContador_2
		FROM bdinteg:"informix".si_huella_linea 
		WHERE fecha_consulta <> dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> "";
		IF (cContador_5 =='1') THEN
			IF (cContador_2 > 0) THEN
				
				IF (iVacio = 1) THEN
					--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
					LET pTipoMov = '4';
				END IF;
				
				INSERT INTO bdinteg:"informix".si_huella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
															empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, 
															tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, 
						imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				DELETE FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;			
			END IF;
		END IF;
		--ref_coppel, Tipo Persona
        SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona)
		INTO cRefCte, cTipoCte
		FROM bdinteg:"informix".si_cliente cte
		WHERE cte.numcte = pNumCte;
           
        --sexo
        SELECT TRIM(ctepf.sexo)
		INTO cSexo
		FROM bdinteg:"informix".si_ctepf ctepf
		WHERE ctepf.numcte = pNumCte;

		--tiene huella el cliente	
        SELECT COUNT(*) 
        INTO cContador_3
        FROM bdinteg:"informix".si_cte_huella 
        WHERE numcte = pNumCte;
		
		IF (cContador_3 > 0)THEN			
			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte AND estado = 'A';

			--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
			SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), 
					NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
			INTO cSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte
			AND secuencia = cSecuenciaMax;
		END IF;
			
		-- Se insertan registros en la si_huella_linea
		LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
		
		
		
		--Se consulta la huella del cliente, si es el mismo dia se regresan los mismo datos ya consultados
        SELECT COUNT(*) 
        INTO cContador_4
        FROM bdinteg:"informix".si_huella_linea 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
		
		
		IF (cContador_5 =='1') THEN
			IF (cContador_4 = 0) THEN
			
				INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
													empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
													tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES  (pNumCte, dFechaCons, cSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);
			END IF;
		END IF;
		LET cFecUlCam = TO_CHAR(dFechaUltCon);
		LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";
		
		--Se construye trama
		LET cCadena = TRIM(pNumCte) ||"|"|| TRIM(cSecuencia) ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
			||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
			||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
			||"|"|| TRIM(pVerificacion) ||"|";
		
		--INICIA 10 HUELLAS
		IF cContador_5 == '1' THEN
			IF (cContador_6 = 0) THEN

				IF (cContador_3 > 1) THEN
					SELECT MAX(secuencia)
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				END IF;

				-- SE INSERTA TABLA si_huella_linea_dec codigo nuevo proyecto 10 huellas
				SELECT count(numcte) 
				INTO iHuellas_cap 
				FROM bdinteg:"informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
													ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
													fecha_ult_cambio,huellas_cap,fecha_insert)
					VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
								
				END IF; 
				
				SELECT COUNT(numcte) 
				INTO iExiste 
				FROM bdinteg:"informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
				AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal, 
														fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
														tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
														fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
							tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
							origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
							codret_result
					FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
					
					-- SELECT ticket 
					-- INTO cTicket 
					-- FROM bdinteg:"informix".si_huella_linea_dec 
					-- WHERE numcte = pNumCte
					-- AND secuencia = cSecuenciaDec;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																	fecha_nac,situacion,causa,activo)
						SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
						FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
				END IF;
				
				
			 
			END IF;		 
		END IF;
	ELSE
		LET cCodRet = '00001';
		LET cCadena = 'El cliente no existe en la si_cliente';
	END IF;

	RETURN cCodRet, TRIM(cCadena);
END;
END PROCEDURE

DOCUMENT
'Inserta registro en si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agrega un insert a la si_huella_linea_dec y a la si_huella_linea_dec_hist',
'Modifico: Carlos Vazquez Mitre',
'Fecha: 31/01/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Para RQI 63 730 Comparacion en linea 10 huellas, se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 890 Se agrega una consulta a la si_cte_huella_dec_actual para saber si hay algun cambio en las huellas. Se anadieron las variables cContador_5 y cContador_6 para evitar que se anadan campos a la tablas si no hay nuevas huellas',
'Modifico: Jahaziel Eduardo Heredia Hinojosa',
'Fecha: 29/12/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_generahuellalinea_chl(pNumCte CHAR(20),pIP CHAR(15),pTipoMov CHAR(2),pEmpleado CHAR(8),pVerificacion CHAR(2), pSensor CHAR(2))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(2000) 	AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 	INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cCadena		CHAR(2000);
	DEFINE dFechaCons	DATETIME YEAR TO DAY;
	DEFINE smSecuencia	SMALLINT;
	DEFINE cGeneraTrama	CHAR(1);
	DEFINE smSec_linea	SMALLINT;
	DEFINE cSexo		CHAR(1);
	DEFINE cSucursal	CHAR(4);
	DEFINE cFechAlta	CHAR(10);
	DEFINE cHuellaD		CHAR(942);
	DEFINE cHuellaI		CHAR(942);
	DEFINE cStatuHuella CHAR(1);
	DEFINE cRefCte		CHAR(20);
	DEFINE dFechaUltCon	DATETIME YEAR TO SECOND;
	DEFINE cTipoCte		CHAR(2);
	DEFINE cTicket		CHAR(20);
	DEFINE cStatusCons	CHAR(1);
	DEFINE cRspMsj601	CHAR(1);
	DEFINE cFechaAlt	CHAR(10);
	DEFINE cFecUlCam	CHAR(18);
	DEFINE dFecha_alta_prueba 	DATE;
	DEFINE iExiste		SMALLINT;
	DEFINE iHuellas_cap 		SMALLINT;
	DEFINE cSecuenciaDec 		INTEGER;
	--DEFINE cContador_3			INTEGER;
	DEFINE iVacio				SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';
	LET cCadena		 = "";
	LET dFechaCons	 = TODAY;
	LET smSecuencia	 = 0;
	LET cGeneraTrama = '0';
	LET smSec_linea	 = 0;
	LET cSexo		 = "";
	LET cSucursal	 = "";
	LET cFechAlta	 = "";
	LET cHuellaD	 = "";
	LET cHuellaI	 = "";
	LET cStatuHuella = "";
	LET cRefCte		 = "";
	LET dFechaUltCon = CURRENT YEAR TO SECOND;
	LET cTipoCte	 = "";
	LET cTicket		 = "";
	LET cStatusCons  = "0";
	LET cRspMsj601   = "";
	LET cFechaAlt	 = "";
	LET cFecUlCam	 = "";
	LET dFecha_alta_prueba 	= TODAY;
	LET iExiste				= 0;
	LET iHuellas_cap 		= 0;
	LET cSecuenciaDec 		= 1;
	--LET cContador_3  		= 0;
	LET iVacio				= 0;
	


	--SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_chl_PropuestaFinal.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cCadena;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) THEN
			
			--Controlar pTipoMov vacio
			IF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL ) THEN
				LET pTipoMov = '1';
				LET iVacio = 1;
			END IF;
			
			SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona), TRIM(ctepf.sexo)
			INTO cRefCte, cTipoCte, cSexo
			FROM bdinteg:"informix".si_cliente cte,
				 bdinteg:"informix".si_ctepf ctepf
			WHERE cte.numcte = pNumCte
			AND ctepf.numcte = pNumCte;
				
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte)THEN
				--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
				SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
				INTO smSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
				FROM bdinteg:"informix".si_cte_huella 
				WHERE numcte = pNumCte
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte AND estado = 'A');
			END IF;
			
			--Fecha Consulta
			SELECT fecha_hoy INTO dFechaCons FROM bdinteg:"informix".si_fechas;
			LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
			
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND status_consulta <> "") THEN
				-- Se actualiza registro en la si_huella_linea
				SELECT NVL(secuencia ,'0'), NVL(ticket,'')
				INTO smSec_linea, cTicket
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				IF smSecuencia > smSec_linea THEN	
				
					IF (iVacio = 1) THEN
						--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
						LET pTipoMov = '4';
					END IF;
				
					INSERT INTO bdinteg:"informix".si_huella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert)
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
					
					INSERT INTO bdinteg:"informix".si_huella_linea_resultado_hist_chl (estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, 
								nombre, fecha_nac, situacion, causa)
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					DELETE FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
										
					DELETE FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					LET cTicket = '';
					
					INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
								empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, 
								respuesta_msj601)
					VALUES	(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
							pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte, pVerificacion, cTicket, cStatusCons, 
							cRspMsj601);
					/*UPDATE bdinteg:"informix".si_huella_linea SET fecha_consulta = dFechaCons, secuencia = smSecuencia, sexo = cSexo, sucursal = cSucursal, 
						   fecha_alta_huella = TO_DATE(cFechaAlt, "%Y-%m-%d"), ip = pIP, tipo_mov_huella = pTipoMov, empleado = pEmpleado, tipo_sensor = pSensor, 
						   dmapa = cHuellaD, imapa = cHuellaI, status_huella = cStatuHuella, ref_coppel = cRefCte, fecha_ult_cambio = dFechaUltCon, tipo_cliente = cTipoCte,
							tipo_verificacion = pVerificacion , ticket = cTicket, status_consulta = cStatusCons, respuesta_msj601 = cRspMsj601, fecha_insert = CURRENT
					WHERE numcte = pNumCte;*/

					LET cGeneraTrama = '1';
				ELSE
					LET cCodRet = '00002';
					LET cCadena = 'El registro no afecto si_huella_linea porque ya existe';
				END IF;
			ELSE
				INSERT INTO bdinteg:"informix".si_huella_linea(	numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
																empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
																tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);

				LET cGeneraTrama = '1';
			END IF;
			
	
			
			IF cGeneraTrama = '1' THEN
				LET cFecUlCam = TO_CHAR(dFechaUltCon);
				LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";

				--Se construye trama
				LET cCadena = TRIM(pNumCte) ||"|"|| smSecuencia ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
					||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
					||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
					||"|"|| TRIM(pVerificacion) ||"|";
			END IF;
					
					--tiene huella el cliente	
        --SELECT COUNT(*) 
        --INTO cContador_3
        --FROM bdinteg:"informix".si_cte_huella 
        --WHERE numcte = pNumCte;
		
	
			
		-- INICIA 10 HUELLAS
		
				
			 --IF (cContador_3 > 1) THEN
				SELECT MAX(secuencia) 
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				--END IF;
				
				-- SE INSERTA TABLA si_huella_linea_dec
				SELECT count(numcte) 
					INTO iHuellas_cap 
				FROM "informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte
					AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO "informix".si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
																		ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
																		fecha_ult_cambio,huellas_cap,fecha_insert)
						VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
				END IF;
				
				SELECT COUNT(numcte) 
					INTO iExiste 
				FROM "informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
					AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO "informix".si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,
						fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
						tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
						fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
						tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
						origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
						codret_result
					FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
					
					-- SELECT ticket 
						-- INTO cTicket 
					-- FROM "informix".si_huella_linea_dec 
					-- WHERE secuencia = cSecuenciaDec 
						-- AND numcte = pNumCte;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																		fecha_nac,situacion,causa,activo)
							SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
							FROM "informix".si_huella_linea_dec_result 
							WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM "informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
				END IF;
				
		
		ELSE
			LET cCodRet = '00001';
			LET cCadena = 'El cliente no existe en la si_cliente';
		END IF;

		RETURN cCodRet, TRIM(cCadena);
	END

END PROCEDURE

DOCUMENT
'Inserta registro en bdinteg:si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'**************************************************************************************',
'MODIFICACION:Se modifica para eliminar el UPDATE de la tabla si_huella_linea cuando ya exista registro de las huellas del cliente,',
'en su lugar realizara un movimiento de la informacion al historico y despues insertara el(los) nuevo(s) registro(s)',
'SUSTENTA: RQI 64 060',
'FECHA : 03/DICIEMBRE/2014',
'MODIFICACION:Se modifica el tipo de dato de las variables smSecuencia y smSec_linea para evitar problemas funcionales en el proceso',
'SUSTENTA: RQI 64 166',
'FECHA : 15/JUNIO/2016',
'**************************************************************************************',
'MODIFICACION:Se modifica para generar el registro en si_huella_linea_dec y si aplica generar los historicos',
'Autor : Narciso Cisneros',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA : 25/MARZO/2022',
'----------------------------------------------------------------------------',
'MOFICACION:se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'MOFICACION:se elimina la validacion cuando la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 05/01/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inserta_actividad_economica_cliente(p_NumCte CHAR(20), p_Sucursal CHAR(4), p_Ejecutivo CHAR(8),  p_Actividad CHAR(100))
        RETURNING CHAR(6);
		
		DEFINE v_CodRet 				VARCHAR(5);
		DEFINE sql_err                  INTEGER;
        DEFINE isam_err                 INTEGER;
        DEFINE error_info               VARCHAR(60);
		DEFINE v_Existe					INTEGER;
		
		DEFINE v_Fecha					DATETIME year to second;
		
		LET v_CodRet					='00000';
		LET sql_err                     = 0;
        LET isam_err                    = 0;
        LET error_info                  = "";
		LET v_Existe					= 0;
		LET v_Fecha						= CURRENT;
		BEGIN
                ON EXCEPTION SET sql_err, isam_err, error_info
                        LET v_CodRet = sql_err;
                        RETURN v_CodRet;
                END EXCEPTION;
				
				SELECT  count(*) INTO v_Existe FROM si_cliente WHERE numcte = p_NumCte;
				
				IF v_Existe <=0 THEN
					LET v_CodRet = '00001';
				ELSE
					INSERT INTO si_cliente_actividad_economica (empresa, numcte, sucursal, ejecutivo, fecha_insert, actividad_economica) 
					VALUES('001',p_NumCte,p_Sucursal,p_Ejecutivo,v_Fecha,p_Actividad);
				END IF;
				
				RETURN v_CodRet;
		END
END PROCEDURE
DOCUMENT
'SP para Insertar actividad economica del cliente cuando se corra la calificaciÃ³n inicial de riesgo de cliente',
'AUTOR : Eduardo Ãvila PÃ©re Tagle',
'Area: Sitemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Miguel Angel Mendoza Maldonado',
'Fecha: 01/Mayo/2024',
'Version: 2.0.0',
'BD: bdinteg',
'Requerimiento: RQM 11 178 CalificaciÃ³n inicial de riesgo de cliente';

CREATE PROCEDURE "informix".sp_wsenviohuellas(fechaActual DATE,registros INT)

RETURNING
        CHAR(5)   as ccCodRetorno,
        char(100) as mensaje,
        CHAR(10)  as cCliente_coppel,
        CHAR(10)  as cCliente_banco,
        CHAR(10)  as cUsuario,
        CHAR      as cSexo,
        CHAR      as cCompany,
        CHAR      as cstore_number,
        CHAR      as cStatus_huella,
        date      as dFecha_insert,
        CHAR      as cDpositiond,
        CHAR      as cDsecuencia,
        CHAR(942) as cDMapa,
        CHAR      as cIpositiond,
        CHAR      as cIsecuencia,
        CHAR(942) as cIMapa;


DEFINE  ccCodRetorno    CHAR(5);
DEFINE  mensaje         char(100);                                                                        
DEFINE  cCliente_coppel CHAR(10);
DEFINE  cCliente_banco  CHAR(10);
DEFINE  cUsuario        CHAR(10);
DEFINE  cSexo           CHAR;
DEFINE  cCompany        CHAR;
DEFINE  cstore_number   CHAR;
DEFINE  cStatus_huella  CHAR;
DEFINE  dFecha_insert   date;
DEFINE  cDpositiond     CHAR;
DEFINE  cDsecuencia     CHAR;
DEFINE  cDMapa          CHAR(942);
DEFINE  cIpositiond     CHAR;
DEFINE  cIsecuencia     CHAR;
DEFINE  cIMapa          CHAR(942);
DEFINE  iNumreg         INTEGER;
DEFINE  sql_err         INTEGER;
DEFINE  isam_err        INTEGER;
DEFINE  vcodret1        INTEGER;
DEFINE  vcodret2        INTEGER;

LET  ccCodRetorno       = '00000';
LET  mensaje            = 'EXITO' ;
LET  cCliente_coppel    = '';
LET  cCliente_banco     = '';
LET  cUsuario           = '';
LET  cSexo              = '';
LET  cCompany           = '';
LET  cstore_number      = '';
LET  cStatus_huella     = '';
LET  dFecha_insert      = mdy(01,01,1900);
LET  cDpositiond        = '';
LET  cDsecuencia        = '';
LET  cDMapa             = '';
LET  cIpositiond        = '';
LET  cIsecuencia        = '';
LET  cIMapa             = '';
LET  iNumreg            = 0;

BEGIN

        ON EXCEPTION SET sql_err, isam_err
            IF sql_err <> 0 THEN
                                LET ccCodRetorno = sql_err;
                                LET mensaje = 'NUM ISAM ERR: '|| isam_err || ' ' || "SQL";
            RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,TODAY,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/EPG/sp_wsenviohuellas.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
        IF   ( registros IS NULL OR registros = '' OR registros < 0  ) THEN
                LET ccCodRetorno = '00002';
                LET mensaje = "Valor de variable registros no validos";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF

        DELETE FROM sp_temphuella;
		
        INSERT INTO  bdinteg:cte_coppel_huella 
        SELECT a.numcte_coppel,0,c.numcte_banco, CURRENT TIMESTAMP,a.fecha_insert,'' 
        FROM clientes_coppel_envia_xml a 
        LEFT JOIN cte_coppel_huella b ON a.numcte_coppel = b.numcte_coppel 
        LEFT JOIN si_relacion_ctebcplcpl c ON c.cliente = a.numcte_coppel
        WHERE b.numcte_coppel IS NULL AND a.fecha_insert >= MDY(month (fechaActual),day (fechaActual),year(fechaActual));
 

        INSERT INTO  bdinteg:sp_temphuella 
        SELECT LIMIT registros numcte_coppel, numcte_banco 
		FROM cte_coppel_huella
		--INNER JOIN si_huella_linea AS a on numcte_banco = a.numcte 
		WHERE estatus = 0  
			and date (fec_xml_creacion)= MDY(month (fechaActual),day (fechaActual),year(fechaActual));

					
        FOREACH
              
            SELECT LIMIT registros d.numcte_coppel, d.numcte_banco
            INTO  cCliente_coppel,cCliente_banco
            FROM sp_temphuella AS d
                    
			SELECT empleado, sexo, 5 AS company, 2 AS store_number, status_huella, date (fecha_alta_huella),  2 AS positiond, secuencia, dmapa, 7 AS positiond, secuencia, imapa 
            INTO  cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa
            FROM si_huella_linea AS a 
			WHERE a.numcte = cCliente_banco;	
				
			IF cUsuario is null THEN
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 3, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
			ELSE
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 1, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
				LET iNumreg = iNumreg + 1;     	 

				RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa WITH RESUME;

			END IF;
			
        END FOREACH;


        IF  iNumreg = 0 THEN
                LET ccCodRetorno = '00001';
                LET mensaje = "No se encontro informacion por actualizar";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;

END


END PROCEDURE;