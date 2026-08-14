package mx.scotiabank.nomina.auth;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import mx.scotiabank.nomina.auth.dto.AuthDtos.LoginResponse;
import mx.scotiabank.nomina.auth.dto.AuthDtos.LoginStatus;
import mx.scotiabank.nomina.auth.dto.AuthDtos.SessionToken;
import mx.scotiabank.nomina.usuario.EstadoUsuario;
import mx.scotiabank.nomina.usuario.Usuario;
import mx.scotiabank.nomina.usuario.UsuarioRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Servicio de autenticacion del IAM propio del mock (ADR-ANCE-004).
 *
 * <p>Flujo: {@code login} valida credenciales contra la tabla {@code Usuario} y
 * abre un reto 2FA (RN-08 · toda escritura critica requiere 2FA); {@code verify2fa}
 * valida el codigo y emite el JWT de sesion via {@link JwtIssuer}.
 *
 * <p>El 2FA esta <b>simulado</b> en el mock (codigo fijo aceptado); la interfaz
 * queda declarada para conectar el mecanismo real en prod (DATO-REQUERIDO).
 */
@Service
public class AuthService {

    /** Codigo 2FA aceptado por el mock. En prod: OTP real (DATO-REQUERIDO). */
    static final String MOCK_2FA_CODE = "483920";

    private final UsuarioRepository usuarios;
    private final PasswordEncoder passwordEncoder;
    private final JwtIssuer jwtIssuer;

    /** Retos 2FA en vuelo. En prod: store con TTL (Redis) — aqui basta en memoria para el mock. */
    private final Map<String, UUID> challenges = new ConcurrentHashMap<>();

    public AuthService(UsuarioRepository usuarios, PasswordEncoder passwordEncoder, JwtIssuer jwtIssuer) {
        this.usuarios = usuarios;
        this.passwordEncoder = passwordEncoder;
        this.jwtIssuer = jwtIssuer;
    }

    @Transactional
    public LoginResponse login(String email, String password) {
        Usuario usuario = usuarios.findByEmailIgnoreCase(email)
                .filter(u -> u.getEstado() == EstadoUsuario.ACTIVO)
                .orElseThrow(() -> new BadCredentialsException("Credenciales invalidas"));

        boolean ok = usuario.getPasswordHash() != null
                && passwordEncoder.matches(password, usuario.getPasswordHash());
        if (!ok) {
            // No se revela si el email existe (mismo mensaje generico).
            throw new BadCredentialsException("Credenciales invalidas");
        }

        String challengeId = "chg_" + UUID.randomUUID().toString().substring(0, 8);
        challenges.put(challengeId, usuario.getIdUsuario());
        // RN-08: siempre se exige 2FA antes de emitir sesion.
        return new LoginResponse(LoginStatus.PENDING_2FA, challengeId, null);
    }

    @Transactional
    public SessionToken verify2fa(String challengeId, String code) {
        UUID idUsuario = Optional.ofNullable(challenges.get(challengeId))
                .orElseThrow(() -> new BadCredentialsException("Reto 2FA invalido o expirado"));

        if (!MOCK_2FA_CODE.equals(code)) {
            throw new BadCredentialsException("Codigo 2FA invalido");
        }

        Usuario usuario = usuarios.findById(idUsuario)
                .orElseThrow(() -> new BadCredentialsException("Usuario no encontrado"));
        challenges.remove(challengeId);

        var issued = jwtIssuer.issue(
                usuario.getIdUsuario(), usuario.getIdEmpresa(), usuario.getEmail(), usuario.getRol());
        // refreshToken simulado en el mock (rotacion real en prod).
        String refresh = "rt_" + UUID.randomUUID();
        return new SessionToken(issued.accessToken(), refresh, issued.expiresIn(), issued.rol());
    }
}
