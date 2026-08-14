package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 2    FAN-OUT : 6    LOC approx: 560
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@Service
public class MerService101 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final MerRepository087 merRepository087;
    private final MoneyUtils moneyUtils;
    private final RbacService rbacService;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
