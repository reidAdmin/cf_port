package port;

import org.springframework.security.web.context.AbstractSecurityWebApplicationInitializer;

import port.SecurityConfig;

public class SecurityWebApplicationInitializer extends AbstractSecurityWebApplicationInitializer {
	
	public SecurityWebApplicationInitializer() {
		super(SecurityConfig.class);
	}
	
}
