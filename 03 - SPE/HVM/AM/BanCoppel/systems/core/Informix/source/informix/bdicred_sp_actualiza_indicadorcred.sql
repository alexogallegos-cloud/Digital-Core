CREATE PROCEDURE "informix".sp_actualiza_indicadorcred()

returning
          char(06) as resultado,
          char(80) as mensaje;

define Sql_error                              integer;
define vEmpresa                               char(3);
define vNumproceso                            char(4);
define cCodRet                                char(6);
define vHora                                  char(8);
define vMes                                   char(12);
define vNumcredito                            char(20);
define iCodRet, isam_err                      integer;
define cMensajeRet, cMensajeBita, error_info  char(80);
define vfecha, df_primer_compra               date;

define vmonto_primer_compra                   decimal(18,2);


let Sql_error = 0;
let cCodRet = '000000';
let iCodRet = 0;
let cMensajeRet = 'EL PROCESO SE REALIZÓ EXITOSAMENTE';
let vfecha = date(1);
let vMes = '';                let vNumcredito = '';
let vNumproceso = '0051';     let vHora = '';
let isam_err = 0;             let error_info = '';
let cMensajeBita = '';        let vEmpresa = '001';

BEGIN
    ON EXCEPTION SET iCodRet, isam_err, error_info
            IF iCodRet <> 0 THEN
            let cCodRet = iCodRet;
            let cMensajeRet = error_info;

            --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
            --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
            --     VALUES(vEmpresa, vNumproceso, today, cCodRet, cMensajeRet, 'informix', today, vHora);
            
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

  --Set debug file to "/informix/macf/sp_actualiza_indicadorcred.trc";
  --Trace on;
  
  --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
  --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
  --    VALUES(vEmpresa, vNumproceso, today, cCodRet, 'Proceso Inicializado', 'informix', today, vHora);


  SET ISOLATION TO dirty READ;
  SELECT num_credito, 
         nvl(f_primer_compra, date(1)) as f_primer_compra, 
         nvl(monto_primer_compra,0) as monto_primer_compra
    FROM bdicred:sd_indicador_cred
   WHERE empresa = vEmpresa
     AND nvl(f_primer_compra, date(1)) <> date(1)
     AND nvl(fecha_ultima_compra,date(1)) = date(1)
     INTO temp paso_compras with no log;

  CREATE UNIQUE INDEX inx_paso_compras ON paso_compras(num_credito);
  
  UPDATE statistics medium FOR TABLE paso_compras; 

  FOREACH WITH HOLD
      SELECT num_credito, f_primer_compra, monto_primer_compra
        INTO vNumcredito, df_primer_compra, vmonto_primer_compra
        FROM paso_compras
        
        BEGIN WORK;
              UPDATE bdicred:sd_indicador_cred
                 SET fecha_ultima_compra = df_primer_compra , monto_ultima_compra = vmonto_primer_compra
                WHERE empresa = vEmpresa  AND num_credito =  vNumcredito; 
        COMMIT WORK;  

  END FOREACH;
  
  UPDATE statistics medium FOR TABLE bdicred:sd_indicador_cred;
  
  
  --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
  --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
  --  VALUES(vEmpresa, vNumproceso, today, cCodRet, 'Proceso Finalizado', 'informix', today, vHora);

  RETURN cCodRet,cMensajeRet ;

END;

END PROCEDURE;