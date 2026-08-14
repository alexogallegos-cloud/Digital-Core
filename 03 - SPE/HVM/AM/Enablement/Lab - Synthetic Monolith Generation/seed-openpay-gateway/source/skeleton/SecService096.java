package com.openpay.api.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : security
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 1    FAN-OUT : 11    LOC approx: 502
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecRequest;

@Service
public class SecService096 {

    // Collaborators (match the graph call edges):
    private final ApiKeyService apiKeyService;
    private final InfService019 infService019;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final RbacService rbacService;
    private final SecRepository035 secRepository035;
    private final SecRepository079 secRepository079;
    private final SecService025 secService025;
    private final SecService207 secService207;
    private final StringUtils stringUtils;
    private final UserService userService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
