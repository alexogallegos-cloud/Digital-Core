CREATE PROCEDURE "informix".sp_valida_cambio_status( psecuencial INTEGER, pvaloranterior CHAR(50), pvalornuevo CHAR(50) )

    DEFINE vCodigoRetorno CHAR(10);
    LET vCodigoRetorno = ''; 
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_valida_cambio_status.out";
    --- TRACE ON; 
    
    IF ( ( TRIM(pvaloranterior) = 'CAN' AND TRIM(pvalornuevo) = 'ACT' ) OR ( TRIM(pvaloranterior) = 'ACT' AND TRIM(pvalornuevo) = 'INA' )  ) THEN

{
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5591970623',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;
}
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5537319377',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5539775952',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5543885549',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;			
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5537319325',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','2','','','','','BD: WARNING! Cambio en estatus de tarejta, secuencial: '||psecuencial||'','','','','','','','5540778776',1,0,0,0,0,current,'')
        INTO vCodigoRetorno;
    END IF;
    
END PROCEDURE;