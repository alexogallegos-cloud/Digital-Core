package mx.scotiabank.nomina.auth;

import jakarta.validation.Valid;
import mx.scotiabank.nomina.auth.dto.AuthDtos.LoginRequest;
import mx.scotiabank.nomina.auth.dto.AuthDtos.LoginResponse;
import mx.scotiabank.nomina.auth.dto.AuthDtos.SessionToken;
import mx.scotiabank.nomina.auth.dto.AuthDtos.TwoFactorRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Endpoints de autenticacion (tag {@code auth}). operationIds del OpenAPI:
 * {@code login}, {@code verify2fa}. Ambos publicos (sin Bearer).
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /** operationId: login. */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest body) {
        return ResponseEntity.ok(authService.login(body.email(), body.password()));
    }

    /** operationId: verify2fa. */
    @PostMapping("/2fa/verify")
    public ResponseEntity<SessionToken> verify2fa(@Valid @RequestBody TwoFactorRequest body) {
        return ResponseEntity.ok(authService.verify2fa(body.challengeId(), body.code()));
    }
}
