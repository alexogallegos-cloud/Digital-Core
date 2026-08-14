package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 253
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class InfController094 {

    // Collaborators (match the graph call edges):
    private final InfService006 infService006;
    private final InfService195 infService195;
    private final RbacService rbacService;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
