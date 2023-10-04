package com.zam.rks.security.configuration;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@AllArgsConstructor
@Component
public class VersionFilter implements Filter {
	public static final String EXPECTED_VERSION = "0.0.7";
	private static final int SC_UPGRADE_REQUIRED = 426;
	private static final Logger logger = LoggerFactory.getLogger(VersionFilter.class);

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		if (!checkAppVersion(request, response)) return;
		chain.doFilter(request, response);
	}

	public static boolean checkAppVersion(ServletRequest request, ServletResponse response) throws IOException {
		String appVersion = ((HttpServletRequest) request).getHeader("App-Version");
		if (appVersion != null && !appVersion.equals(EXPECTED_VERSION)) {
			((HttpServletResponse) response).setStatus(SC_UPGRADE_REQUIRED);
			response.setContentType("text/plain");
			response.setCharacterEncoding("UTF-8");
			response.getWriter().write("Invalid application version");
			logger.warn("User: " + ((HttpServletRequest) request).getAttribute("username")
					+ " tried to use endpoint: '" + ((HttpServletRequest) request).getRequestURI()
					+ "' with invalid app version: " + appVersion
					+ ", expected version: " + EXPECTED_VERSION
					+ " from: " + ((HttpServletRequest) request).getRemoteAddr() + " "
					+ ((HttpServletRequest) request).getHeader("user-agent"));
			return false;
		}
		return true;
	}


}
