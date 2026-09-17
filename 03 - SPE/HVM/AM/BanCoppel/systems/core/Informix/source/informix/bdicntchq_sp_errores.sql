CREATE PROCEDURE "informix".sp_errores( pfecha        date,  -- Fecha
                             phora         char(10),  -- hora
                             pcuenta       char(20),  -- Cuenta
                             pcod_error    Char(5),   -- Codigo de error
                             psp_llamado   Char(40),   -- SP que se ejecuto
                             pmensaje      Char(200), -- Mensaje de Error
                             pusuario      Char(8)    -- Usuario
                                            );
       --returning     char(5);   -- vcodret

--insertar en errores
INSERT INTO sq_errores(fecha_proceso, hora_proceso, cuenta, cod_error, sp_llamado, mensaje_error, usuario) 
    VALUES(pfecha, phora, pcuenta, pcod_error, psp_llamado, pmensaje, pusuario);

    
--end
end procedure;