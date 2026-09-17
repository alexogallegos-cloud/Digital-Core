CREATE PROCEDURE "informix".sp_corrige_capitalizacion()

RETURNING char(6),char(80);


    DEFINE cCodRet                  char(6);
    DEFINE cMensaje                 char(80);
    DEFINE sql_err                  integer;
    DEFINE isam_err                 integer;
    DEFINE cSql                     char(1024);

----variables de cuadre de vencido
    DEFINE v_numcredito             char(20);
    DEFINE v_monto                  DECIMAL(18,2);
    DEFINE v_codigoref              SMALLINT;
    DEFINE v_sucursal               char(4);

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
     drop table creditos_cap;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

    LET cCodRet = "000000";
    LET cMensaje = "PROCESO EXITOSO";
    LET cSql= "";

    LET v_numcredito = "";
    LET v_monto=0;      
    LET v_codigoref =0;  
    LET v_sucursal="";
 
 -- SET DEBUG FILE TO "compone_vencidos_AA.out";
 -- TRACE ON;
        create table creditos_cap
        ( num_credito  char(20),
          monto        decimal(18,2),
          codigo_ref   integer,
          sucursal     char(4));
        
            -- cifras de control
            LET cSql = 'echo "load from ' || '''creditos.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' insert into creditos_cap ' ||
                                ' " > querycarga_creditos.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred querycarga_creditos.sql';
              SYSTEM cSql;


    FOREACH WITH HOLD 

        select num_credito,monto,codigo_ref,sucursal
        into v_numcredito,v_monto,v_codigoref,v_sucursal
        from creditos_cap
       
        BEGIN WORK;

           IF v_codigoref=2 THEN
              CALL genmov('001',v_numcredito,'6001',5,'605',today,v_monto,
                          'ccap'||trim(v_numcredito),v_sucursal,'01','') 
              RETURNING cCodRet, cMensaje;
           ELSE
              CALL genmov('001',v_numcredito,'6001',6,'605',today,v_monto,
                          'ccap'||trim(v_numcredito),v_sucursal,'01','') 
              RETURNING cCodRet, cMensaje;
           END IF;

           update bdicred:sd_maesdos 
           set sdo_intereses=sdo_intereses-(v_monto*67*(today-mdy('08','21','2009'))/36000),
               sdo_cap_insoluto=sdo_cap_insoluto-v_monto,
               sdo_capital=sdo_capital-v_monto
           where empresa='001' and num_credito=v_numcredito;

 
        COMMIT WORK;

    END FOREACH;

    drop table creditos_cap;

 RETURN cCodRet,cMensaje;

END PROCEDURE;