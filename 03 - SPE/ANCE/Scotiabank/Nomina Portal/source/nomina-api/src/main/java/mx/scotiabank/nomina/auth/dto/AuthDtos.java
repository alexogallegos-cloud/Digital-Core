package mx.scotiabank.nomina.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import mx.scotiabank.nomina.usuario.Rol;

/**
 * DTOs de autenticacion (schemas del OpenAPI: LoginRequest, LoginResponse,
 * TwoFactorRequest, SessionToken). Records inmutables (Java 21).
 */
public final class AuthDtos {

    private AuthDtos() {
    }

    /** {@code LoginRequest}. */
    public record LoginRequest(
            @NotBlank @Email String email,
            @NotBlank String password) {
    }

    /** {@code LoginResponse} · status AUTHENTICATED | PENDING_2FA. */
    public record LoginResponse(
            LoginStatus status,
            String challengeId,
            String accessToken) {
    }

    public enum LoginStatus {AUTHENTICATED, PENDING_2FA}

    /** {@code TwoFactorRequest}. */
    public record TwoFactorRequest(
            @NotBlank String challengeId,
            @NotBlank String code) {
    }

    /** {@code SessionToken}. {@code expiresIn} en segundos (<= 3600). */
    public record SessionToken(
            String accessToken,
            String refreshToken,
            long expiresIn,
            Rol rol) {
    }
}
