package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : JOB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 95
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Scheduled
public class InfJob012 {

    // Collaborators (match the graph call edges):
    private final InfService006 infService006;
    private final InfService125 infService125;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
