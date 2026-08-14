CREATE PROCEDURE "informix".spei_depuratblabono() 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vContador3           INTEGER;
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    DEFINE wintnumserial        integer;
    DEFINE wmnyimporte          decimal(19,2);
    DEFINE wcvecesifbcoord      integer;
    DEFINE wchrestatusenvio     char(1);
    DEFINE wvchrnombreord       varchar(40,0);
    DEFINE wvchrcuentaord       varchar(20,0);
    DEFINE wvchrrfcord          varchar(18,0);
    DEFINE wintcvetipoctaord    integer;
    DEFINE wvchrnombrebenef     varchar(40,0);
    DEFINE wintcvetipoctabene   integer;
    DEFINE wvchrcuentabenef     varchar(20,0);
    DEFINE wintrefnumerica      decimal(7,0);
    DEFINE wvchrrefcobranza     varchar(40,0);
    DEFINE wvchrconceptopago2   varchar(40,0);
    DEFINE wdtfechavalor        date;
    DEFINE wdtfechacaptura      date;
    DEFINE wvchrclaverastreo    varchar(30,0);
    DEFINE wvchrcuentachq       varchar(20,0);
    DEFINE wvchrnumctechq       varchar(20,0);
    DEFINE wvchrctabenefemail   varchar(20,0);
    DEFINE wvchrtpoctabenefmsg  varchar(25,0);
    DEFINE wvchrtransacc        char(4);
    DEFINE wvchrfoliosuc        varchar(30,0);
    DEFINE wchrtipopago         CHAR(2);
    DEFINE wchridmjc            CHAR(20);
    DEFINE wchrfchmjc           CHAR(20);
    DEFINE wchrnumcelord        CHAR(10);
    DEFINE wintdigidord         INTEGER;
    DEFINE wchrnumcelben        CHAR(20);
    DEFINE wintdigidben         INTEGER;
    DEFINE wchrnumseriecert     CHAR(20);
    DEFINE iCommit              INTEGER;    
    DEFINE pfecha_hoy           DATE;
	DEFINE fecha				DATE;
	DEFINE pfecha_ant			DATE;
    
    DEFINE wfechalimpago CHAR(16);
    DEFINE wpagocomision INTEGER;
    DEFINE wcomision 		DECIMAL(14,2);
    DEFINE wfolioplataforma CHAR(20);
    DEFINE wvchrfirma       CHAR(512);
    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '';
    LET vCodRet3            = '';  
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vContador3          = 0;
    LET vComienza           = -1;
    LET vAbierto            = '0';
    LET wintnumserial       = 0;
    LET wmnyimporte         = 0.00;
    LET wcvecesifbcoord     = 0;
    LET wchrestatusenvio    = '';
    LET wvchrnombreord      = '';
    LET wvchrcuentaord      = '';
    LET wvchrrfcord         = '';
    LET wintcvetipoctaord   = 0;
    LET wvchrnombrebenef    = '';
    LET wintcvetipoctabene  = 0;
    LET wvchrcuentabenef    = '';
    LET wintrefnumerica     = 0.00;
    LET wvchrrefcobranza    = '';
    LET wvchrconceptopago2  = '';
    LET wdtfechavalor       = '';
    LET wdtfechacaptura     = '';
    LET wvchrclaverastreo   = '';
    LET wvchrcuentachq      = '';
    LET wvchrnumctechq      = '';
    LET wvchrctabenefemail  = '';
    LET wvchrtpoctabenefmsg = '';
    LET wvchrtransacc       = '';
    LET wvchrfoliosuc       = '';
    LET wchrtipopago        = '';
    LET wchridmjc           = '';
    LET wchrfchmjc          = '';
    LET wchrnumcelord       = '';
    LET wintdigidord        = 0;
    LET wchrnumcelben       = '';
    LET wintdigidben        = 0;
    LET wchrnumseriecert    = '';
    LET iCommit             = 5000;
    LET pfecha_hoy          = '';
	LET fecha				= TODAY;
	LET pfecha_ant			= '';
    
    LET wfechalimpago    = '';
    LET wpagocomision    = 0;
    LET wcomision 	     = 0.00;
    LET wfolioplataforma = '';
    LET wvchrfirma       = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratblabono.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratblabono.out";
	--- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO pfecha_hoy 
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
    
	IF(fecha < pfecha_hoy) THEN
		SELECT fecha_ant
		INTO pfecha_ant
		FROM bdicheq:sc_fechas
		WHERE empresa = '001';
		LET pfecha_hoy = pfecha_ant;
	END IF;
	
	FOREACH WITH HOLD
        SELECT {+INDEX(tblabono idx_tblabono_fecha)}
               intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, 
               intcvetipoctabene, vchrcuentabenef, intrefnumerica, vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, 
               vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
               chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
               fechalimpago, pagocomision, comision, folioplataforma, vchrfirma
          INTO wintnumserial, wmnyimporte, wcvecesifbcoord, wchrestatusenvio, wvchrnombreord, wvchrcuentaord, wvchrrfcord, wintcvetipoctaord, wvchrnombrebenef, 
               wintcvetipoctabene, wvchrcuentabenef, wintrefnumerica, wvchrrefcobranza, wvchrconceptopago2, wdtfechavalor, wdtfechacaptura, wvchrclaverastreo, 
               wvchrcuentachq, wvchrnumctechq, wvchrctabenefemail, wvchrtpoctabenefmsg, wvchrtransacc, wvchrfoliosuc,
               wchrtipopago, wchridmjc, wchrfchmjc, wchrnumcelord, wintdigidord, wchrnumcelben, wintdigidben, wchrnumseriecert,
               wfechalimpago, wpagocomision, wcomision, wfolioplataforma, wvchrfirma
          FROM tblabono 
         WHERE dtfechavalor = pfecha_hoy
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        INSERT INTO tblhistabono
        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, 
          intcvetipoctabene, vchrcuentabenef, intrefnumerica, vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, 
          vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma )
        VALUES
        ( wintnumserial, wmnyimporte, wcvecesifbcoord, wchrestatusenvio, wvchrnombreord, wvchrcuentaord, wvchrrfcord, wintcvetipoctaord, wvchrnombrebenef, 
          wintcvetipoctabene, wvchrcuentabenef, wintrefnumerica, wvchrrefcobranza, wvchrconceptopago2, wdtfechavalor, wdtfechacaptura, wvchrclaverastreo, 
          wvchrcuentachq, wvchrnumctechq, wvchrctabenefemail, wvchrtpoctabenefmsg, wvchrtransacc, wvchrfoliosuc,
          wchrtipopago, wchridmjc, wchrfchmjc, wchrnumcelord, wintdigidord, wchrnumcelben, wintdigidben, wchrnumseriecert,
          wfechalimpago, wpagocomision, wcomision, wfolioplataforma, wvchrfirma );
          
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            DELETE FROM tblabono
             WHERE dtfechavalor = pfecha_hoy 
               AND vchrclaverastreo = wvchrclaverastreo
               AND intnumserial = wintnumserial;
               
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                LET vcontador3 = vcontador3 + 1;
            END IF;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= iCommit THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET wintnumserial = 0;
        LET wvchrclaverastreo = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;