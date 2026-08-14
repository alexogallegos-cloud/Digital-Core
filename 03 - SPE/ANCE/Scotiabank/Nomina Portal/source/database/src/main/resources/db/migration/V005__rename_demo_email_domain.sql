-- V005 · Renombra el dominio de correo del mock: @empresa-demo.mx -> @empresa.mx
-- (más fácil de teclear en el login del demo). No toca el dominio interno del
-- banco (@scotiabank-demo.mx). Idempotente vía LIKE + REPLACE.

-- Usuarios de empresa (login del portal).
UPDATE Usuario
   SET email = REPLACE(email, '@empresa-demo.mx', '@empresa.mx')
 WHERE email LIKE '%@empresa-demo.mx';

-- Correos de contacto en los centros de trabajo (JSON) — consistencia visual.
UPDATE CentroTrabajo
   SET contactos = REPLACE(contactos, '@empresa-demo.mx', '@empresa.mx')
 WHERE contactos LIKE '%@empresa-demo.mx%';
