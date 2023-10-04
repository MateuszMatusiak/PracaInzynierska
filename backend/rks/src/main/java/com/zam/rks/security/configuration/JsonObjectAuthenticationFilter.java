package com.zam.rks.security.configuration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zam.rks.model.LoginCredentials;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;

import static com.zam.rks.security.configuration.VersionFilter.checkAppVersion;

public class JsonObjectAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

	private final ObjectMapper objectMapper;

	public JsonObjectAuthenticationFilter(ObjectMapper objectMapper) {
		this.objectMapper = objectMapper;
	}

	@Override
	public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
		try {
			BufferedReader reader = request.getReader();
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
			LoginCredentials authRequest = objectMapper.readValue(sb.toString(), LoginCredentials.class);
			request.setAttribute("username", authRequest.email());
			if (!checkAppVersion(request, response)) {
				return null;
			}
			String usernameAndDevice = String.format("%s%s%s", authRequest.email().trim(), String.valueOf(Character.LINE_SEPARATOR), authRequest.deviceToken().trim());
			UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
					usernameAndDevice, authRequest.password()
			);
			setDetails(request, token);
			return this.getAuthenticationManager().authenticate(token);
		} catch (IOException e) {
			throw new IllegalArgumentException(e.getMessage());
		}
	}
}
