CREATE PROCEDURE "informix".pasecheqfinal(pempresa CHAR(3))
RETURNING CHAR(5);
    
DEFINE GLOBAL vgcodigo_mn           CHAR(2)        DEFAULT ' ';
DEFINE GLOBAL vg_sistema            CHAR(2)        DEFAULT ' ';
DEFINE GLOBAL vgtransacc_t1         CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vgtransacc_t2         CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL vgtransacc_corresp    CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vfecha_hoy            DATE           DEFAULT TODAY;
    
DEFINE vcodret          CHAR(5);
DEFINE vcodret2         CHAR(5);
DEFINE vcodret3         VARCHAR(50);
DEFINE vsqlerr          INTEGER;
DEFINE visamerr         INTEGER;
DEFINE vdescerr         VARCHAR(50);
DEFINE vsucopero        CHAR(4);
DEFINE vproducto        CHAR(4);
DEFINE vmoneda          CHAR(2);
DEFINE vtransacc        CHAR(4);
DEFINE vmonto_tot       MONEY(14,2);
DEFINE vexento_isr      CHAR(1);
DEFINE vsector          CHAR(2);
DEFINE vvaloriza        CHAR(1);
DEFINE vcancelad        CHAR(1);
DEFINE vsuccta          CHAR(4);
DEFINE wabreviatura     VARCHAR(20);
DEFINE wdescripcion     VARCHAR(30);
DEFINE vfechaproc       DATE;
DEFINE vporcentaje      DECIMAL(9,6);
DEFINE vtasa_bruta      DECIMAL(9,6);
DEFINE vsobretasa       DECIMAL(9,6);
DEFINE vtpcambval       DECIMAL(14,6);
DEFINE vmonto1          MONEY(14,2);
DEFINE vmonto2          MONEY(14,2);
DEFINE vdivisa_cambio   CHAR(2);
DEFINE vtranprovint     CHAR(4);
DEFINE vcobraisr        CHAR(1);
DEFINE vexiste          INTEGER;
DEFINE vexistefin       INTEGER;
DEFINE vproceso         VARCHAR(10);
DEFINE vsistema         CHAR(2);
DEFINE vestatusproc     CHAR(1);
DEFINE vusuario         VARCHAR(10);
DEFINE vhora_tc         DATETIME HOUR TO MINUTE;
DEFINE vmincta          VARCHAR(20);
DEFINE vmaxcta          VARCHAR(20);
DEFINE vbintarjeta      CHAR(6);   -- PITDC
DEFINE vsecuencia       INTEGER;   -- PITDC
DEFINE vreferencia      VARCHAR (19); -- PITDC
DEFINE vsql             LVARCHAR(600);
DEFINE vstmt            VARCHAR(250);
DEFINE vcuenta          VARCHAR(20);
DEFINE vsecserv         SMALLINT;
DEFINE vexistepase      SMALLINT;
DEFINE vexistepase1     SMALLINT;
DEFINE vexistepase2     SMALLINT;
DEFINE vexistepase3     SMALLINT;
DEFINE vexistepase4     SMALLINT;
DEFINE vexistepase5     SMALLINT;

LET vcodret             = "000";
LET vcodret2            = "";
LET vcodret3            = "";
LET vsqlerr             = 0;
LET visamerr            = 0;
LET vdescerr            = "";
LET vsucopero           = "";
LET vproducto           = "";
LET vmoneda             = "";
LET vtransacc           = "";
LET vmonto_tot          = "";
LET vexento_isr         = "";
LET vsector             = "";
LET vvaloriza           = "";
LET vcancelad           = "";
LET vsuccta             = "";
LET wabreviatura        = "";
LET wdescripcion        = "";
LET vfechaproc          = "";
LET vporcentaje         = "";
LET vtasa_bruta         = "";
LET vsobretasa          = "";
LET vtpcambval          = "";
LET vmonto1             = "";
LET vmonto2             = "";
LET vdivisa_cambio      = "";
LET vtranprovint        = "";
LET vcobraisr           = "";
LET vexiste             = "";
LET vexistefin          = "";
LET vproceso            = "pasechqfinal";
LET vsistema            = "01";
LET vestatusproc        = "";
LET vusuario            = USER;
LET vhora_tc            = "";
LET vmincta             = "";
LET vmaxcta             = "";
LET vbintarjeta         = "";   -- PITDC
LET vsecuencia          = 0;   -- PITDC
LET vreferencia         = ""; -- PITDC
LET vsql                = '';
LET vstmt               = '';
LET vcuenta             = "";
LET vsecserv            = 0;
LET vexistepase         = 0;
LET vexistepase1        = 0;
LET vexistepase2        = 0;
LET vexistepase3        = 0;
LET vexistepase4        = 0;
LET vexistepase5        = 0;


BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
       SET debug FILE TO "/tmp/pasecheqfinal.out";
       TRACE ON;
       IF vsqlerr <> 0 THEN
	      --Se elimina System y el campo empresa
          UPDATE bdinteg:sx_contproc 
             SET ejecutivo   = vusuario,
                 status_proc = 'C',
                 codret      = vcodret,
                 hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa )
           WHERE proceso = vproceso
             AND fecha   = vfecha_hoy
             AND sistema = vsistema; 		   
	   
          RETURN vcodret;
       END IF;
    END EXCEPTION;

    --SET debug FILE TO "/home/c98789058/SPL_ACCENTURE/pasecheqfinal.out";
    --TRACE ON;
    
    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

    -- // Asigna la fecha de hoy
	--Se elimina campo empresa del where
    SELECT fecha_ant 
      INTO vfecha_hoy
      FROM bdicheq:sc_fechas
	 WHERE empresa = pempresa;	 
	 
     
    -- // VALIDA SI YA SE EJECUTO EL PROCESO DEL DIA 
    --Se elimina campo empresa del where	
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;	   
	   

    IF vexiste = 0 THEN
	   --Se elimina System 
       INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret)
       VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario,
                  (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);	   
    ELSE
	   IF NOT EXISTS (SELECT proceso FROM bdinteg:sx_contproc
                       WHERE proceso     = vproceso
                         AND fecha       = vfecha_hoy
                         AND sistema     = vsistema
                         AND status_proc = 'F' ) THEN 
          --Se elimina System y el campo empresa						 
		  UPDATE bdinteg:sx_contproc
             SET ejecutivo   = vusuario,
                 status_proc = 'I',
                 codret      = ' ',
                 hora_ini    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
           WHERE proceso  = vproceso
             AND fecha    = vfecha_hoy
             AND sistema  = vsistema;		   
       ELSE
          LET vcodret = "963";
		  --Se elimina System y el campo empresa
          UPDATE bdinteg:sx_contproc
             SET ejecutivo   = vusuario,
                 status_proc = 'C',
                 codret      = vcodret,
                 hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
           WHERE proceso  = vproceso
             AND fecha    = vfecha_hoy
             AND sistema  = vsistema;			   
		   
		   
       END IF
    END IF;
     
	 
	--Para prueba de ejecuciÃ³n
	--LET vfecha_hoy ='01/04/2026';
    -- // Verifica se hayan efectuado todos los complementos del pase contable
	--Se elimina campo empresa del where
    SELECT COUNT(*)
      INTO vexistepase
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechq"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';
	   
    --Se elimina campo empresa del where  
    SELECT COUNT(*)
      INTO vexistepase1
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechqcomp1"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';	
	   
    --Se elimina campo empresa del where       
    SELECT COUNT(*)
      INTO vexistepase2
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechqcomp2"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';	   
       
    --Se elimina campo empresa del where	   
    SELECT COUNT(*)
      INTO vexistepase3
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechqcomp3"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';	   
    
	--Se elimina campo empresa del where
    SELECT COUNT(*)
      INTO vexistepase4
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechqcomp4"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';	   
     
	--Se elimina campo empresa del where 
    SELECT COUNT(*)
      INTO vexistepase5
      FROM bdinteg:sx_contproc
     WHERE proceso = "pasechqcomp5"
       AND fecha   = vfecha_hoy
       AND sistema = vsistema
       AND status_proc = 'F';	   
    
	
	
    -- // EJECUTA LOS PROCESOS FALTANTES PARA GENERAR LA POLIZA DE CHEQUES
    --//Comentar este IF para ejecuciÃ³n de pruebas
	IF vexistepase <= 0 OR vexistepase1 <= 0 OR vexistepase2 <= 0 OR vexistepase3 <= 0 OR vexistepase4 <= 0 OR vexistepase5 <= 0 THEN
       LET vcodret = "974";
	   
	   --Se elimina System y el campo empresa
       UPDATE bdinteg:sx_contproc
          SET ejecutivo   = vusuario,
              status_proc = 'C',
              codret      = vcodret,
              hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
        WHERE proceso  = vproceso
          AND fecha    = vfecha_hoy
          AND sistema  = vsistema;	           	   
        RETURN vcodret;
    END IF;
       
    -- // EJECUTA LOS PROCESOS FALTANTES PARA GENERAR LA CONTABILIDAD DEL SISTEMA DE CHEQUES
    CALL auditor(pempresa) 
    RETURNING vcodret;

    IF vcodret = "000" THEN
        CALL pasecont(pempresa,vfecha_hoy,vfecha_hoy,'') 
        RETURNING vcodret;
        
        IF vcodret = "000" THEN
           UPDATE bdicheq:sc_contproc
              SET fecha = vfecha_hoy
            WHERE proceso = "pase";			   
			   
			   
        END IF;
    END IF;

    IF vcodret <> "000" THEN
       LET vestatusproc = "C";
    ELSE
       LET vestatusproc = "F";
    END IF;
	
    UPDATE bdinteg:sx_contproc
       SET status_proc = vestatusproc,
           codret      = vcodret,
           hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
     WHERE proceso  = vproceso
       AND fecha    = vfecha_hoy
       AND sistema  = vsistema;		
    
    IF vcodret = "000" THEN
       CALL sp_integra_suspenso ('001','01',vfecha_hoy) RETURNING vcodret;
    END IF

    RETURN vcodret;

END;
END PROCEDURE;