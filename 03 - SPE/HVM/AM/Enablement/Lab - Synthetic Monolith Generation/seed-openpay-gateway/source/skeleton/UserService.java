package com.openpay.dashboard.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : security
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 48    FAN-OUT : 5    LOC approx: 795
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecEntity;

@Service
public class UserService {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final RbacService rbacService;
    private final SecRepository035 secRepository035;
    private final SecRepository078 secRepository078;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
