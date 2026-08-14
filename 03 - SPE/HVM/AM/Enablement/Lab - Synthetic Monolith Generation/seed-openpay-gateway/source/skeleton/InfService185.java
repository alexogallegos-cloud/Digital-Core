package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 8    LOC approx: 458
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService185 {

    // Collaborators (match the graph call edges):
    private final InfRepository016 infRepository016;
    private final InfRepository039 infRepository039;
    private final InfService065 infService065;
    private final InfService105 infService105;
    private final InfService211 infService211;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final RbacService rbacService;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
