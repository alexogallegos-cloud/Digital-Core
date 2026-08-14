CREATE PROCEDURE "informix".sp_capintafecha_status( pCuenta CHAR(20), pFecha DATE )
RETURNING CHAR(5), DECIMAL(14,2), DECIMAL(14,2), CHAR(1);

    DEFINE cCodret      CHAR(5);
    DEFINE cCodret2     CHAR(5);
    DEFINE cCodret3     CHAR(50);
    DEFINE cSQL_ERR     INTEGER;
    DEFINE cISAM_ERR    INTEGER;
    DEFINE cDESC_ERR    CHAR(50);
    DEFINE cAnioMes     CHAR(6);
    DEFINE vCapital     DECIMAL(14,2);
    DEFINE vInteres     DECIMAL(14,2);
    DEFINE vdia         CHAR(2);
    DEFINE vStatus      CHAR(1);

    LET cCodret   = '000';
    LET cCodret2  = '000';
    LET cCodret3  = '000';
    LET cSQL_ERR  = 0;
    LET cISAM_ERR = 0;
    LET cDESC_ERR = '';
    LET cAnioMes  = '';
    LET vCapital  = 0.00;
    LET vInteres  = 0.00;
    LET vdia      = '';
    LET vStatus   = '';

    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_capintafecha.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_capintafecha.err';
        TRACE ON;
        LET cCodret = cSQL_ERR;
        LET cCodret2 = cISAM_ERR;
        LET cCodret3 = cDESC_ERR;
        RETURN cCodret, vCapital, vInteres, vStatus;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET vdia = DAY(pFecha);
    LET vdia = TRIM(vdia);
    
    LET cAnioMes = SUBSTR(pFecha,7,4) || SUBSTR(pFecha,1,2);
    LET cAnioMes = cAnioMes;
    
    SELECT {+INDEX(bdicheq:sc_sdodiarioc isdodiario)} 
           DECODE( vdia, '1',  capvig1,  
                         '2',  capvig2,  
                         '3',  capvig3,  
                         '4',  capvig4,  
                         '5',  capvig5,   
                         '6',  capvig6,  
                         '7',  capvig7,
                         '8',  capvig8,  
                         '9',  capvig9, 
                        '10', capvig10, 
                        '11', capvig11, 
                        '12', capvig12, 
                        '13', capvig13, 
                        '14', capvig14, 
                        '15', capvig15, 
                        '16', capvig16, 
                        '17', capvig17, 
                        '18', capvig18, 
                        '19', capvig19, 
                        '20', capvig20, 
                        '21', capvig21, 
                        '22', capvig22, 
                        '23', capvig23,
                        '24', capvig24, 
                        '25', capvig25, 
                        '26', capvig26, 
                        '27', capvig27, 
                        '28', capvig28, 
                        '29', capvig29, 
                        '30', capvig30, 
                        '31', capvig31 ), 
           DECODE( vdia, '1',  intprovnp1,   
                         '2',  intprovnp2,   
                         '3',  intprovnp3,  
                         '4',  intprovnp4,   
                         '5',  intprovnp5, 
                         '6',  intprovnp6, 
                         '7',  intprovnp7, 
                         '8',  intprovnp8,
                         '9',  intprovnp9, 
                        '10', intprovnp10,
                        '11', intprovnp11, 
                        '12', intprovnp12, 
                        '13', intprovnp13, 
                        '14', intprovnp14, 
                        '15', intprovnp15,
                        '16', intprovnp16, 
                        '17', intprovnp17, 
                        '18', intprovnp18, 
                        '19', intprovnp19, 
                        '20', intprovnp20,
                        '21', intprovnp21, 
                        '22', intprovnp22, 
                        '23', intprovnp23, 
                        '24', intprovnp24, 
                        '25', intprovnp25,
                        '26', intprovnp26, 
                        '27', intprovnp27, 
                        '28', intprovnp28, 
                        '29', intprovnp29, 
                        '30', intprovnp30,
                        '31', intprovnp31 ) ,
           DECODE( vdia, '1',  statuscta1,   
                         '2',  statuscta2,   
                         '3',  statuscta3,  
                         '4',  statuscta4,   
                         '5',  statuscta5, 
                         '6',  statuscta6, 
                         '7',  statuscta7, 
                         '8',  statuscta8,
                         '9',  statuscta9, 
                        '10', statuscta10,
                        '11', statuscta11, 
                        '12', statuscta12, 
                        '13', statuscta13, 
                        '14', statuscta14, 
                        '15', statuscta15,
                        '16', statuscta16, 
                        '17', statuscta17, 
                        '18', statuscta18, 
                        '19', statuscta19, 
                        '20', statuscta20,
                        '21', statuscta21, 
                        '22', statuscta22, 
                        '23', statuscta23, 
                        '24', statuscta24, 
                        '25', statuscta25,
                        '26', statuscta26, 
                        '27', statuscta27, 
                        '28', statuscta28, 
                        '29', statuscta29, 
                        '30', statuscta30,
                        '31', statuscta31 )
      INTO vCapital, vInteres, vStatus
      FROM bdicheq:"informix".sc_sdodiarioc 
     WHERE cuenta = pCuenta
       AND aniomes = cAnioMes;
       
    IF vCapital = '' OR vCapital IS NULL THEN
        -- // CUENTA NO EXISTE EN FECHA
        LET cCodret = '100'; 
        LET vCapital = 0.00;
        LET vInteres = 0.00;
        LET vStatus = '0';
    END IF;

    RETURN cCodret, vCapital, vInteres, vStatus;

    END;

END PROCEDURE;