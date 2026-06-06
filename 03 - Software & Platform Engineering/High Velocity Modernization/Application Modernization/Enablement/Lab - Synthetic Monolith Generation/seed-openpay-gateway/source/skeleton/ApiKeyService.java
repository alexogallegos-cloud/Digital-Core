package com.openpay.api.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : security
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 22    FAN-OUT : 6    LOC approx: 695
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecEntity;

@Service
public class ApiKeyService {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final JdbcReadGateway jdbcReadGateway;
    private final SecRepository023 secRepository023;
    private final SecRepository050 secRepository050;
    private final SecRepository061 secRepository061;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
