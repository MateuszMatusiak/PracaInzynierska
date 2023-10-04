package com.zam.rks.security.configuration;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zam.rks.Dto.Mapper.UserDtoMapper;
import com.zam.rks.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class RestAuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

	private final long expirationTime;
	private final String secret;
	private final ObjectMapper objectMapper;
	private static final Logger logger = LoggerFactory.getLogger(RestAuthenticationSuccessHandler.class);


	public RestAuthenticationSuccessHandler(
			@Value("${jwt.expirationTime}") long expirationTime,
			@Value("${jwt.secret}") String secret, ObjectMapper objectMapper) {
		this.expirationTime = expirationTime;
		this.secret = secret;
		this.objectMapper = objectMapper;
	}

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
										Authentication authentication) throws IOException {
		User user = (User) authentication.getPrincipal();
		String token = JWT.create()
				.withSubject(user.getUsername())
				.withExpiresAt(new Date(System.currentTimeMillis() + expirationTime))
				.sign(Algorithm.HMAC256(secret));
		response.addHeader("Authorization", token);
		response.setCharacterEncoding("UTF-8");
		response.setContentType("application/json");

		if (!user.isEnabled() || !user.hasRequiredData()) {
			response.setStatus(HttpStatus.UNAUTHORIZED.value());
			Map<String, Object> errorDetails = new HashMap<>();
			if (!user.isEnabled()) {
				errorDetails.put("message", "Email not verified");
				logger.warn("User: " + user.getId() + " tried to log in from: " + request.getRemoteAddr() + " " + request.getHeader("user-agent") + " without email verification");
			} else if (!user.hasRequiredData()) {
				errorDetails.put("message", "Not provided additional data");
				logger.warn("User: " + user.getId() + " tried to log in from: " + request.getRemoteAddr() + " " + request.getHeader("user-agent") + " without extra data");
			}
			errorDetails.put("user", UserDtoMapper.mapToDto(user));
			response.getWriter().write(objectMapper.writeValueAsString(errorDetails));
			return;
		}
		response.setStatus(HttpStatus.OK.value());
		response.getWriter().write(objectMapper.writeValueAsString(UserDtoMapper.mapToDto(user)));
		logger.info("User: " + user.getId() + " logged in from: " + request.getRemoteAddr() + " " + request.getHeader("user-agent"));
	}
}