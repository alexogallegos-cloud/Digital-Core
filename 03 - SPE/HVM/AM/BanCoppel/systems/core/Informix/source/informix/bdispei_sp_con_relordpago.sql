CREATE PROCEDURE "informix".sp_con_relordpago(
                        pconsulta_tipo       smallint,      --Por día(1) o Historico(0)
                        ptipo_pago           integer ,      --Tipo de Pago
                        psentido             char(1),       --Criterio por sentido
                        pbanco_rec           integer,       --Criterio por banco recibido
                        pbanco_env           integer,       --Criterio por banco enviado
                        ptipooperacion       char(2),       --Tipo de operación
                        pestatus             char(1),       --Criterio por Estatus
                        prango_de            date,          --Criterio x rangos de fecha
                        prango_hasta         date,          --Criterio x rangos hasta fecha
                        pregistro            INTEGER,      --Control del número de registros
                        P_BanContar          INTEGER  --CHAR(1)        --BANDERA PARA HACER EL COUNT
                        )

RETURNING
   char(5),        date,             
   varchar(111,0), varchar(111,0), varchar(10,0), varchar(50,0),
   varchar(31,0),  varchar(20,0),  varchar(40,0), integer,
   decimal(19,2),  varchar(31,0),  varchar(20,0), varchar(40,0),
   integer,        varchar(30,0),  varchar(250,0),varchar(111,0),
   varchar(255),   integer ,       datetime hour to fraction,integer,
   smallint,       integer,       integer,       smallint;


--
--********************************************************************************************************
--*
--*         DEFINICIÓN DE VARIABLES
--*
--
--********************************************************************************************************

-- Variables Generales

DEFINE    vcodret          char(5);
DEFINE    vsqlerr          integer;

DEFINE LVintpkpago          integer;
DEFINE LVdtfechavalor       date;
DEFINE LVintcvetipopago     integer;
DEFINE LVtipopago           varchar(111,0);
DEFINE LVcvecesifbcoord     integer;
DEFINE LVcesifbcoord        varchar(31,0);
DEFINE LVvchrcuentaord      varchar(20,0);
DEFINE LVvchrnombreord      varchar(40,0);
DEFINE LVintcvetipoctaord   integer;
DEFINE LVmnyimporte         decimal(19,2);
DEFINE LVcvecesifbcodest    integer   ;
DEFINE LVcesifbcodest       varchar(31,0);
DEFINE LVvchrcuentabenef    varchar(20,0);
DEFINE LVvchrnombrebenef    varchar(40,0);
DEFINE LVintcvetipoctabene  integer;
DEFINE LVvchrclaverastreo   varchar(30,0);
DEFINE LVchrestatusenvio    varchar(50,0);
DEFINE LVintcvetpooperacion integer;
DEFINE LVcvetpooperacion    varchar(111,0);
DEFINE LVchrsentidopago     char(1);
DEFINE LVsentidopago        varchar(10,0);
DEFINE LVvchrdescripcion    varchar(250,0);
DEFINE LVintcvecausadev     varchar(111,0);
DEFINE LVvchrmotivodev      varchar(255);
DEFINE LVintrefnumerica     integer   ;
DEFINE LVdtmhoracargo       datetime hour to fraction(3);
DEFINE vciclo               smallint;
DEFINE vultimo_tanto        smallint;
DEFINE LVtotal_registros    integer;
DEFINE vresiduo             smallint;
DEFINE LVtotal_paginas      smallint;
DEFINE LVprimer_registro    smallint;
DEFINE LVultimo_registro    smallint;
DEFINE LVpagina_actual      smallint;
DEFINE LVauxiliar_paginas   INTEGER;
--********************************************************************************************************
--*
--*         ASIGNACIÓN DE VARIABLES
--*
--
--********************************************************************************************************

-- Variables Generales --

LET    vcodret         = "000";
LET    vsqlerr         = "0";


LET LVintpkpago         =0;
LET LVdtfechavalor      ="";
LET LVintcvetipopago    =0;
LET LVtipopago          ="";
LET LVcvecesifbcoord    =0;
LET LVcesifbcoord       ="";
LET LVvchrcuentaord     ="";
LET LVvchrnombreord     ="";
LET LVintcvetipoctaord  =0;
LET LVmnyimporte        =0;
LET LVcvecesifbcodest   =0;
LET LVcesifbcodest      ="";
LET LVvchrcuentabenef   ="";
LET LVvchrnombrebenef   ="";
LET LVintcvetipoctabene =0;
LET LVvchrclaverastreo  ="";
LET LVchrestatusenvio   ="";
LET LVintcvetpooperacion  =0;
LET LVcvetpooperacion   ="";
LET LVchrsentidopago    ="";
LET LVsentidopago       ="";
LET LVvchrdescripcion   ="";
LET LVintcvecausadev    ="";
LET LVvchrmotivodev     ="";
LET LVintrefnumerica    =0;
LET LVdtmhoracargo      ="";
LET vciclo              =1;
LET vultimo_tanto       =0;
LET LVtotal_registros   =0;
LET vresiduo            =0;
LET LVtotal_paginas     =0;
LET LVprimer_registro   =0;
LET LVultimo_registro   =0;
LET LVpagina_actual     =0;
LET LVauxiliar_paginas  =0;

--
--********************************************************************************************************
--*
--*         CONTROL DE ERRORES
--*
--
--********************************************************************************************************

BEGIN

  ON EXCEPTION SET  vsqlerr
     IF  vsqlerr <>  0 THEN
         LET vcodret=vsqlerr;
         RETURN vcodret,         LVdtfechavalor,         
                LVtipopago,      LVcvetpooperacion, LVsentidopago,     LVchrestatusenvio,  
                LVcesifbcoord,   LVvchrcuentaord,   LVvchrnombreord,   LVintcvetipoctaord,
                LVmnyimporte,    LVcesifbcodest,    LVvchrcuentabenef, LVvchrnombrebenef, 
                LVintcvetipoctabene, LVvchrclaverastreo, LVvchrdescripcion, LVintcvecausadev,
                LVvchrmotivodev, LVintrefnumerica,  LVdtmhoracargo,    LVtotal_registros,
                LVtotal_paginas, LVprimer_registro, LVultimo_registro, LVpagina_actual;

     END IF;
   END EXCEPTION;

   --SET DEBUG FILE TO "/tmp/sp_con_relordpago.out";
  --TRACE ON;


--
--*********************************************************************************************************
--*
--*         PROGRAMA PRINCIPAL
--*
--********************************************************************************************************


      --************************************************
      -- Extrae los datos    *
      --************************************************

    IF P_BanContar = 0  THEN
       IF pconsulta_tipo = "1" THEN
    
          SELECT count(*)
            INTO LVtotal_registros
            FROM tblpago,
                 tbltipopago,
                 tblbanco,
           OUTER tblcausadev,
           OUTER tbltipooperacion
           WHERE tblpago.intCveTipoPago = tbltipopago.intCveTipoPago
             AND tblpago.cvecesifbcodest = tblbanco.cvecesif
             AND tblpago.intcvecausadev = tblcausadev.intcvecausadev
             AND tblpago.intcvetpooperacion = tbltipooperacion.intcvetpooperacion::smallint
             --AND tblpago.intcvetipopago = DECODE(ptipo_pago,999,tblpago.intcvetipopago,ptipo_pago::int)
             AND tbltipopago.intcvetipopago =  DECODE(ptipo_pago,999,tbltipopago.intcvetipopago,ptipo_pago::int)
             AND tblpago.chrsentidopago = DECODE(psentido,'S',tblpago.chrsentidopago,psentido)
             AND tblpago.cvecesifbcoord = DECODE(pbanco_rec,0,tblpago.cvecesifbcoord,pbanco_rec)
             AND tblpago.cvecesifbcodest = DECODE(pbanco_env,0,tblpago.cvecesifbcodest,pbanco_env)
             AND nvl(tblpago.intcvetpooperacion,0) = DECODE(
                                                       ptipooperacion,'S',nvl(tblpago.intcvetpooperacion,0),ptipooperacion)
             AND tblpago.chrestatusenvio = DECODE(pestatus,'S',tblpago.chrestatusenvio,pestatus) ;
      ELIF pconsulta_tipo = '0'  THEN
                 
            SELECT count(*)
              INTO LVtotal_registros
              FROM tblhistpago hist, tbltipopago,
                   tblbanco,
             OUTER tblcausadev,
             OUTER tbltipooperacion
             WHERE hist.intCveTipoPago = tbltipopago.intCveTipoPago
               AND hist.chrsentidopago =DECODE(psentido,'S',hist.chrsentidopago,psentido)
               AND hist.chrestatusenvio = DECODE(pestatus,'S',hist.chrestatusenvio,pestatus)
               AND tblbanco.cvecesif = hist.cvecesifbcodest
               AND hist.intcvecausadev = tblcausadev.intcvecausadev
               AND tbltipooperacion.intcvetpooperacion::smallint = hist.intcvetpooperacion
               AND tbltipopago.intcvetipopago =  DECODE(ptipo_pago,999,tbltipopago.intcvetipopago,ptipo_pago::int)
               AND hist.cvecesifbcoord = DECODE(pbanco_rec,0,hist.cvecesifbcoord,pbanco_rec)
               AND hist.cvecesifbcodest = DECODE(pbanco_env,0,hist.cvecesifbcodest,pbanco_env)
               AND nvl(hist.intcvetpooperacion,0) = DECODE(ptipooperacion,
                                                                  'S',nvl(hist.intcvetpooperacion,0),
                                                                   ptipooperacion)
               AND hist.dtfechavalor >= DECODE(prango_de,'00/00/0000',hist.dtfechavalor ,prango_de)
               AND hist.dtfechavalor <= DECODE(prango_hasta,'00/00/0000',hist.dtfechavalor,prango_hasta);
 
{
             WHERE hist.intCveTipoPago = tbltipopago.intCveTipoPago
               AND hist.cvecesifbcodest = tblbanco.cvecesif
               AND hist.intcvecausadev = tblcausadev.intcvecausadev
               AND hist.intcvetpooperacion = tbltipooperacion.intcvetpooperacion::smallint
               AND hist.intcvetipopago =DECODE(ptipo_pago,999,hist.intcvetipopago,ptipo_pago)
               AND hist.chrsentidopago =DECODE(psentido,'S',hist.chrsentidopago,psentido)
               AND hist.cvecesifbcoord = DECODE(pbanco_rec,0,hist.cvecesifbcoord,pbanco_rec)
               AND hist.cvecesifbcodest = DECODE(pbanco_env,0,hist.cvecesifbcodest,pbanco_env)
               AND nvl(hist.intcvetpooperacion,0) = DECODE(ptipooperacion,
                                                                  'S',nvl(hist.intcvetpooperacion,0),
                                                                   ptipooperacion)
               AND hist.chrestatusenvio = DECODE(pestatus,'S',hist.chrestatusenvio,pestatus);
               AND hist.dtfechavalor >= DECODE(prango_de,'00/00/0000',hist.dtfechavalor ,prango_de)
               AND hist.dtfechavalor <= DECODE(prango_hasta,'00/00/0000',hist.dtfechavalor ,prango_hasta);
}
      END IF;    
   ELSE
       LET LVtotal_registros =  P_BanContar; 
   END IF;
 

 
           IF LVtotal_registros <> 0 THEN
                 Let vresiduo = mod(LVtotal_registros,100);
                 IF vresiduo <> 0 THEN
                      Let LVtotal_paginas = LVtotal_registros / 100;
                   --   LET LVtotal_paginas = LVtotal_paginas + 1;
 
                     Let LVauxiliar_paginas = LVtotal_paginas*100;
                     Let LVtotal_paginas = LVtotal_paginas + 1;
                     Let LVauxiliar_paginas = LVtotal_registros + 1;
                 ELSE
                      Let LVtotal_paginas = LVtotal_registros / 100;
                 END IF
           END IF
  
    
           Let vultimo_tanto = pregistro + 99 ;
           Let LVultimo_registro = vultimo_tanto;
           Let LVprimer_registro = pregistro;

           if pregistro = 1 then
              LET LVpagina_actual = 1;
           else  
              LET LVpagina_actual = pregistro/100;
              LET LVpagina_actual = LVpagina_actual +1;
           end if;

           IF pconsulta_tipo = "1" THEN
               FOREACH
                 SELECT skip pregistro first 100
                        dtfechavalor,          tblpago.intcvetipopago||' '||tbltipopago.vchrdescripcion as tipopago ,
                        cvecesifbcoord||' - '||(SELECT vchrnombrecorto FROM tblbanco WHERE cvecesif=cvecesifbcoord) as 
                        cesifbcoord,           vchrcuentaord ,           
                        vchrnombreord ,        intcvetipoctaord ,     
                        mnyimporte ,           cvecesifbcodest||' - '||tblbanco.vchrnombrecorto as cesifbcodest ,
                        vchrcuentabenef ,      vchrnombrebenef ,
                        intcvetipoctabene ,    vchrclaverastreo ,
                        DECODE
                          (chrestatusenvio,'L', 'Liquidada',       'I','Intención Pago',
                                           'M','por Devolver',     'A','Abonada',
                                           'D','Devuelta',         'B','por Abonar', 
                                           'P','por Autorización', 'E','Enviada',
                                           'X','por   Autreversar','R','Recibida',
                                           'N', 'Pendiente Enviar','T','por Enviar', 
                                           'W','Cancelada SPEI',   'C','Cancelada',
                                           'Q','Reenvio',          'K', 'Recibiendo',   'Otro') chrestatusenvio , 
                        tblpago.intcvetpooperacion ,
                        tblpago.intcvetpooperacion||tbltipooperacion.vchrdescripcion as cvetpooperacion ,
                        chrsentidopago ,        DECODE(chrsentidopago,'E','ENVIADO','RECIBIDO') as sentidopago ,
                        vchrconceptopago||vchrconceptopago2 as vchrdescripcion ,
                        tblpago.intcvecausadev||' '||tblcausadev.vchrdescripcion as intcvecausadev ,
                        vchrmotivodev ,
                        intrefnumerica ,
   		        dtmhoracargo
                  INTO
                       LVdtfechavalor,          LVtipopago,
                       LVcesifbcoord,           LVvchrcuentaord,
                       LVvchrnombreord,         LVintcvetipoctaord,
                       LVmnyimporte,            LVcesifbcodest,
                       LVvchrcuentabenef,       LVvchrnombrebenef,
                       LVintcvetipoctabene,     LVvchrclaverastreo,
                       LVchrestatusenvio,
                       LVintcvetpooperacion,
                       LVcvetpooperacion,
                       LVchrsentidopago,        LVsentidopago,
                       LVvchrdescripcion,
                       LVintcvecausadev,
                       LVvchrmotivodev,
                       LVintrefnumerica,
                       LVdtmhoracargo
                  FROM
                      tblpago,
                      tbltipopago,
                      tblbanco,
                 OUTER tblcausadev,
                 OUTER tbltipooperacion
                 WHERE tblpago.intCveTipoPago = tbltipopago.intCveTipoPago
                   AND tblpago.cvecesifbcodest = tblbanco.cvecesif
                   AND tblpago.intcvecausadev = tblcausadev.intcvecausadev
                   AND tblpago.intcvetpooperacion = tbltipooperacion.intcvetpooperacion::smallint
                   AND tbltipopago.intcvetipopago =  DECODE(ptipo_pago,999,tbltipopago.intcvetipopago,ptipo_pago::int)
                   AND tblpago.chrsentidopago = DECODE(psentido,'S',tblpago.chrsentidopago,psentido)
                   AND tblpago.cvecesifbcoord = DECODE(pbanco_rec,0,tblpago.cvecesifbcoord,pbanco_rec)
                   AND tblpago.cvecesifbcodest = DECODE(pbanco_env,0,tblpago.cvecesifbcodest,pbanco_env)
                   AND nvl(tblpago.intcvetpooperacion,0) = DECODE(
                                                       ptipooperacion,'S',nvl(tblpago.intcvetpooperacion,0),ptipooperacion)
                   AND tblpago.chrestatusenvio = DECODE(pestatus,'S',tblpago.chrestatusenvio,pestatus) 
                 ORDER BY intpkpago
   
{
                 WHERE tblpago.intCveTipoPago = tbltipopago.intCveTipoPago
                   AND tblpago.cvecesifbcodest = tblbanco.cvecesif
                   AND tblpago.intcvecausadev = tblcausadev.intcvecausadev
                   AND tblpago.intcvetpooperacion = tbltipooperacion.intcvetpooperacion::smallint
                   AND tblpago.intcvetipopago = DECODE(ptipo_pago,999,tblpago.intcvetipopago,ptipo_pago::int)
                   AND tblpago.chrsentidopago =DECODE(psentido,'S',tblpago.chrsentidopago,psentido)
                   AND tblpago.cvecesifbcoord = DECODE(pbanco_rec,0,tblpago.cvecesifbcoord,pbanco_rec)
                   AND tblpago.cvecesifbcodest = DECODE(pbanco_env,0,tblpago.cvecesifbcodest,pbanco_env)
                   AND nvl(tblpago.intcvetpooperacion,0) = DECODE(ptipooperacion,
                                                                  'S',nvl(tblpago.intcvetpooperacion,0),
                                                                   ptipooperacion)
                   AND tblpago.chrestatusenvio = DECODE(pestatus,'S',tblpago.chrestatusenvio,pestatus)
                 ORDER BY intpkpago
}

               RETURN
                    vcodret,         LVdtfechavalor,
                    LVtipopago,      LVcvetpooperacion, LVsentidopago,     LVchrestatusenvio,
                    LVcesifbcoord,   LVvchrcuentaord,   LVvchrnombreord,   LVintcvetipoctaord,
                    LVmnyimporte,    LVcesifbcodest,    LVvchrcuentabenef, LVvchrnombrebenef,
                    LVintcvetipoctabene, LVvchrclaverastreo, LVvchrdescripcion, LVintcvecausadev,
                    LVvchrmotivodev, LVintrefnumerica,  LVdtmhoracargo,    LVtotal_registros,
                    LVtotal_paginas, LVprimer_registro, LVultimo_registro, LVpagina_actual
 
               WITH  RESUME;

             END FOREACH;
       ELIF  pconsulta_tipo = '0'  THEN

          FOREACH
            SELECT skip pregistro first 100
                        dtfechavalor ,       hist.intcvetipopago||' '||tbltipopago.vchrdescripcion as tipopago ,
                        cvecesifbcoord||' - '||(SELECT vchrnombrecorto 
                                                  FROM tblbanco 
                                                 WHERE cvecesif=cvecesifbcoord ) as cesifbcoord,
                        vchrcuentaord ,      vchrnombreord ,
                        intcvetipoctaord ,    mnyimporte ,
                        cvecesifbcodest||' - '||tblbanco.vchrnombrecorto as cesifbcodest ,     vchrcuentabenef ,
                        vchrnombrebenef ,    intcvetipoctabene ,
                        vchrclaverastreo ,   DECODE(chrestatusenvio,
                                              'L','Liquidada',            'I','Intención Pago',
                                              'M','por Devolver',         'A','Abonada',
                                              'D','Devuelta',             'B','por Abonar', 
                                              'P','por Autorización',     'E','Enviada',
                                              'X','por   Autreversar' ,   'R','Recibida',
                                              'N', 'Pendiente Enviar',    'T','por Enviar',
                                              'W','Cancelada SPEI',       'C','Cancelada',
                                              'Q','Reenvio',              'K', 'Recibiendo',
                                              'Otro') chrestatusenvio , 
                        hist.intcvetpooperacion, hist.intcvetpooperacion||tbltipooperacion.vchrdescripcion as 
                                                 cvetpooperacion ,
                        chrsentidopago , DECODE(chrsentidopago,'E','ENVIADO','RECIBIDO') as sentidopago ,
                        vchrconceptopago||vchrconceptopago2 as vchrdescripcion ,
                        hist.intcvecausadev||' '||tblcausadev.vchrdescripcion as intcvecausadev ,
                        vchrmotivodev , intrefnumerica ,
                        dtmhoracargo
                  INTO
                       LVdtfechavalor,
                       LVtipopago,
                       LVcesifbcoord,
                       LVvchrcuentaord,
                       LVvchrnombreord,
                       LVintcvetipoctaord,
                       LVmnyimporte,
                       LVcesifbcodest,
                       LVvchrcuentabenef,
                       LVvchrnombrebenef,
                       LVintcvetipoctabene,
                       LVvchrclaverastreo,
                       LVchrestatusenvio,
                       LVintcvetpooperacion,
                       LVcvetpooperacion,
                       LVchrsentidopago,
                       LVsentidopago,
                       LVvchrdescripcion,
                       LVintcvecausadev,
                       LVvchrmotivodev,
                       LVintrefnumerica,
                       LVdtmhoracargo
                 FROM
                      tblhistpago hist,
                      tbltipopago,
                      tblbanco,
                OUTER tblcausadev,
                OUTER tbltipooperacion
                WHERE hist.intCveTipoPago = tbltipopago.intCveTipoPago
                  AND hist.chrsentidopago =DECODE(psentido,'S',hist.chrsentidopago,psentido)
                  AND hist.chrestatusenvio = DECODE(pestatus,'S',hist.chrestatusenvio,pestatus)
                  AND tblbanco.cvecesif = hist.cvecesifbcodest
                  AND hist.intcvecausadev = tblcausadev.intcvecausadev
                  AND tbltipooperacion.intcvetpooperacion::smallint = hist.intcvetpooperacion
                  AND tbltipopago.intcvetipopago =  DECODE(ptipo_pago,999,tbltipopago.intcvetipopago,ptipo_pago::int)
                  AND hist.cvecesifbcoord = DECODE(pbanco_rec,0,hist.cvecesifbcoord,pbanco_rec)
                  AND hist.cvecesifbcodest = DECODE(pbanco_env,0,hist.cvecesifbcodest,pbanco_env)
                  AND nvl(hist.intcvetpooperacion,0) = DECODE(ptipooperacion,
                                                                     'S',nvl(hist.intcvetpooperacion,0),
                                                                      ptipooperacion)
                  AND hist.dtfechavalor >= DECODE(prango_de,'00/00/0000',hist.dtfechavalor ,prango_de)
                  AND hist.dtfechavalor <= DECODE(prango_hasta,'00/00/0000',hist.dtfechavalor,prango_hasta)
                  ORDER BY intpkpago
   
{
                WHERE
                     hist.intCveTipoPago = tbltipopago.intCveTipoPago
                  AND         hist.cvecesifbcodest    = tblbanco.cvecesif
                  AND         hist.intcvecausadev     = tblcausadev.intcvecausadev
                  AND         hist.intcvetpooperacion = tbltipooperacion.intcvetpooperacion::smallint
                  AND         hist.intcvetipopago     = DECODE(ptipo_pago,999,hist.intcvetipopago,ptipo_pago)
                  AND         hist.chrsentidopago     = DECODE(psentido,'S',hist.chrsentidopago,psentido)
                  AND         hist.cvecesifbcoord     = DECODE(pbanco_rec ,0,hist.cvecesifbcoord,pbanco_rec)
                  AND         hist.cvecesifbcodest    = DECODE(pbanco_env,0,hist.cvecesifbcodest,pbanco_env)
                  AND nvl(hist.intcvetpooperacion,0) = DECODE(ptipooperacion,
                                                                  'S',nvl(hist.intcvetpooperacion,0),
                                                                   ptipooperacion)
                  AND         hist.chrestatusenvio    = DECODE(pestatus,'S',hist.chrestatusenvio,pestatus)
                  AND         hist.dtfechavalor >= DECODE(prango_de ,'00/00/0000',hist.dtfechavalor ,prango_de)
                  AND         hist.dtfechavalor <= DECODE(prango_hasta ,'00/00/0000',hist.dtfechavalor ,prango_hasta)
                  ORDER BY intpkpago
}

               RETURN
                    vcodret,         LVdtfechavalor,         
                    LVtipopago,      LVcvetpooperacion, LVsentidopago,     LVchrestatusenvio,  
                    LVcesifbcoord,   LVvchrcuentaord,   LVvchrnombreord,   LVintcvetipoctaord,
                    LVmnyimporte,    LVcesifbcodest,    LVvchrcuentabenef, LVvchrnombrebenef, 
                    LVintcvetipoctabene, LVvchrclaverastreo, LVvchrdescripcion, LVintcvecausadev,
                    LVvchrmotivodev, LVintrefnumerica,  LVdtmhoracargo,    LVtotal_registros,
                    LVtotal_paginas, LVprimer_registro, LVultimo_registro, LVpagina_actual
               WITH  RESUME;

          END FOREACH;
      END IF;
 END

 END PROCEDURE document "Version 1.0.0.1 Iván Guzmán";

CREATE PROCEDURE "informix".sp_refrescabonos(pFechaValor date,
                                             pStatus1 CHAR(1),
                                             pStatus2 CHAR(1),
                                             pStatus3 CHAR(1),
                                             pStatus4 CHAR(1),
                                             pStatus5 CHAR(1),
                                             pStatus6 CHAR(1),
                                             pStatus7 CHAR(1))

RETURNING INTEGER ,CHAR(1),CHAR(1), INTEGER, INTEGER, 
          INTEGER, VARCHAR(20), decimal(19,2), VARCHAR(30), INTEGER,
          VARCHAR(100), INTEGER, VARCHAR(100), INTEGER, INTEGER,
          VARCHAR(100), varchar(255), CHAR(1);

-- ***************************************************************************
-- sp_refrescabonos
-- Version              1.0.0
-- Obejtivo:            Abono Automatico Ordenes de pago a SPEI
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Octubre - 2008
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de variables
DEFINE v_codret          char(5);
DEFINE v_monto_abo       money(16,2);
DEFINE sql_err 	         integer;
DEFINE vintPkPago        integer;
DEFINE vcausadev         INTEGER;
DEFINE vmotivo           CHAR(40);

DEFINE vt_intpkpago	    INTEGER;
DEFINE vt_intfoliopago      INTEGER;
DEFINE vt_cvecesifbcoord    INTEGER;
DEFINE vt_vchrnombrecorto   VARCHAR(20);
DEFINE vt_intcvetpooperacion CHAR(2);
DEFINE vt_vchrdesctipooper  VARCHAR(100);
DEFINE vt_mnyimporte	    decimal(19,2);
DEFINE vt_intcvetipoctaord  INTEGER;
DEFINE vt_vchrdesctipoctaord VARCHAR(100);
DEFINE vt_intcvetipopago    INTEGER;
DEFINE vt_vchrdesctipopago  VARCHAR(100);
DEFINE vt_chrestatusenvio   char(1);
DEFINE vt_vchrnombreord	    VARCHAR(40);
DEFINE vt_vchrcuentaord	    VARCHAR(20);
DEFINE vt_vchrrfcord	    VARCHAR(18);
DEFINE vt_vchrnombrebenef   VARCHAR(40);
DEFINE vt_intcvetipoctabene INTEGER;
DEFINE vt_intcvetipoctaben  INTEGER;
DEFINE vt_vchrdesctipoctaben VARCHAR(100);
DEFINE vt_vchrcuentabenef   VARCHAR(20);
DEFINE vt_vchrrfcbenef	    VARCHAR(18);
DEFINE vt_vchrnombrebenef2  VARCHAR(40);
DEFINE vt_intcvetipoctabene2 INTEGER;
DEFINE vt_vchrcuentabenef2  VARCHAR(20);
DEFINE vt_vchrrfcbenef2	    VARCHAR(18);
DEFINE vt_vchrconceptopago  VARCHAR(210);
DEFINE vt_mnyiva	    decimal(16,2);
DEFINE vt_intrefnumerica    decimal(7);
DEFINE vt_vchrrefcobranza   VARCHAR(40);
DEFINE vt_vchrclavepago	    VARCHAR(10);
DEFINE vt_vchrconceptopago2 VARCHAR(40);
DEFINE vt_dtfechavalor      DATE;
DEFINE vt_dtfechacaptura    date;
DEFINE vt_vchrclaverastreo  VARCHAR(30);
DEFINE vt_chrusuarioprom    VARCHAR(20);
DEFINE vt_chrfolioprom	    char(16);
DEFINE vt_chrusuariovent    VARCHAR(20);
DEFINE vt_chrfolioliqu	    char(16);
DEFINE vt_intfoliopaquete   INTEGER;
DEFINE vt_chrtopologia	    char(1);
DEFINE vt_chrprioridad	    char(1);
DEFINE vt_intfoliocargo	    INTEGER;
DEFINE vt_dtmhoracargo	    date;
DEFINE vt_intcvecausadev    INTEGER;
DEFINE vt_vchrdescripcion   varchar(100);
DEFINE vt_vchrcverastreodev varchar	(30);
DEFINE vt_vchrmotivodev	    varchar(255);



    --SET debug file to "/tmp/sp_refrescabonos.out";
    --TRACE on;

--//INICIA LA FUNCIONALIDAD
BEGIN

        --//Manejo de excepciones
        ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
	       LET v_codret = sql_err;
	           RETURN  null ,null ,null ,null ,null
                        ,null ,null ,null ,null ,null	
                        ,null ,null ,null ,null ,null
                        ,null ,null ,null;
		END IF;
        END EXCEPTION;
        -- Establece Modo de Lectura
        SET isolation to dirty read;
        
        LET v_codret = "000";

	--//Envia los pagos 
        FOREACH
            SELECT x0.intpkpago ,x0.intfoliopago ,x0.cvecesifbcoord ,x7.vchrnombrecorto ,x1.intcvetpooperacion ,
                   x1.vchrdescripcion ,x0.mnyimporte ,x3.intcvetipocuenta ,x3.vchrdescripcion ,x5.intcvetipopago ,
                   x5.vchrdescripcion ,x0.chrestatusenvio ,x0.vchrnombreord ,x0.vchrcuentaord ,x0.vchrrfcord ,
                   x0.vchrnombrebenef ,x0.intcvetipoctabene ,x4.intcvetipocuenta ,x4.vchrdescripcion ,x0.vchrcuentabenef ,
                   x0.vchrrfcbenef ,x0.vchrnombrebenef2 ,x0.intcvetipoctabene2 ,x0.vchrcuentabenef2 ,x0.vchrrfcbenef2 ,
                   x0.vchrconceptopago ,x0.mnyiva ,x0.intrefnumerica ,x0.vchrrefcobranza ,x0.vchrclavepago ,
                   x0.vchrconceptopago2 ,x0.dtfechavalor ,x0.dtfechacaptura ,x0.vchrclaverastreo ,x0.chrusuarioprom ,
                   x0.chrfolioprom ,x0.chrusuariovent ,x0.chrfolioliqu ,x2.intfoliopaquete ,x0.chrtopologia ,x2.chrprioridad ,
                   x0.intfoliocargo ,x0.dtmhoracargo ,x0.intcvecausadev ,x6.vchrdescripcion ,x0.vchrcverastreodev ,
                   x0.vchrmotivodev 
	      INTO vt_intpkpago ,vt_intfoliopago ,vt_cvecesifbcoord ,vt_vchrnombrecorto ,vt_intcvetpooperacion
                  ,vt_vchrdesctipooper ,vt_mnyimporte ,vt_intcvetipoctaord ,vt_vchrdesctipoctaord ,vt_intcvetipopago
                  ,vt_vchrdesctipopago ,vt_chrestatusenvio ,vt_vchrnombreord ,vt_vchrcuentaord ,vt_vchrrfcord	
                  ,vt_vchrnombrebenef ,vt_intcvetipoctabene ,vt_intcvetipoctaben ,vt_vchrdesctipoctaben ,vt_vchrcuentabenef
                  ,vt_vchrrfcbenef ,vt_vchrnombrebenef2 ,vt_intcvetipoctabene2 ,vt_vchrcuentabenef2 ,vt_vchrrfcbenef2
                  ,vt_vchrconceptopago ,vt_mnyiva	   ,vt_intrefnumerica ,vt_vchrrefcobranza ,vt_vchrclavepago
                  ,vt_vchrconceptopago2 ,vt_dtfechavalor     ,vt_dtfechacaptura  ,vt_vchrclaverastreo ,vt_chrusuarioprom  
                  ,vt_chrfolioprom ,vt_chrusuariovent  ,vt_chrfolioliqu ,vt_intfoliopaquete  ,vt_chrtopologia
                  ,vt_chrprioridad ,vt_intfoliocargo ,vt_dtmhoracargo ,vt_intcvecausadev ,vt_vchrdescripcion 
                  ,vt_vchrcverastreodev ,vt_vchrmotivodev 
             FROM "informix".tblpago x0 ,outer("informix".tbltipooperacion x1 ) ,
                   outer("informix".tblpaqueteenv x2 ) ,outer("informix".tbltipocuenta x3 ) 
                   ,outer("informix".tbltipocuenta x4 ) ,outer("informix".tbltipopago x5 ) ,
                   outer("informix".tblcausadev x6 ) ,outer("informix".tblbanco x7 )
             WHERE (((((((((x0.intcvetpooperacion ::integer = x1.intcvetpooperacion ::integer ) 
               AND (x0.intcvetipoctaord = x3.intcvetipocuenta ) ) AND (x0.intcvetipopago = x5.intcvetipopago ) ) 
               AND (x0.intcvetipoctabene = x4.intcvetipocuenta ) ) AND (x0.intpkpaqueteenv = x2.intpkpaqueteenv ) ) 
               AND (x0.intcvecausadev = x6.intcvecausadev ) ) AND (x0.chrsentidopago = 'R' ) ) 
               AND (x0.cvecesifbcoord = x7.cvecesif ))
               AND x0.dtfechavalor = pFechaValor) 
               AND (x0.chrestatusenvio = DECODE(pStatus1,'R',pStatus1,pStatus1) 
                     OR x0.chrestatusenvio = DECODE(pStatus2,'Y',pStatus2,pStatus2)
                     OR x0.chrestatusenvio = DECODE(pStatus3,'A',pStatus3,pStatus3)
                     OR x0.chrestatusenvio = DECODE(pStatus4,'I',pStatus4,pStatus4)
                     OR x0.chrestatusenvio = DECODE(pStatus5,'E',pStatus5,pStatus5)
                     OR x0.chrestatusenvio = DECODE(pStatus6,'M',pStatus6,pStatus6)
                     OR x0.chrestatusenvio = DECODE(pStatus7,'D',pStatus7,pStatus7))


	     RETURN vt_intpkpago ,vt_chrprioridad,vt_chrtopologia, vt_intfoliopago, vt_intfoliopaquete, 
                    vt_cvecesifbcoord, vt_vchrnombrecorto, vt_mnyImporte, vt_vchrclaverastreo, vt_intcvetipopago,
                    vt_vchrdesctipopago, vt_intcvetpooperacion, vt_vchrdesctipooper, vt_intfoliocargo, vt_intcvecausadev,
                    vt_vchrdescripcion, vt_vchrmotivodev, vt_chrestatusenvio WITH RESUME;

        END FOREACH;

END
END PROCEDURE;