package com.zam.rks.security.configuration;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.zam.rks.Service.LoginService;
import com.zam.rks.model.User;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class JwtAuthorizationFilter extends BasicAuthenticationFilter {
	private static final String TOKEN_HEADER = "Authorization";
	private final UserDetailsService userDetailsService;
	private final String secret;

	public JwtAuthorizationFilter(AuthenticationManager authenticationManager,
								  UserDetailsService userDetailsService,
								  String secret) {
		super(authenticationManager);
		this.userDetailsService = userDetailsService;
		this.secret = secret;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
									FilterChain filterChain) throws IOException, ServletException {
		UsernamePasswordAuthenticationToken authentication = getAuthentication(request);
		if (authentication == null) {
			filterChain.doFilter(request, response);
			return;
		}
		SecurityContextHolder.getContext().setAuthentication(authentication);
		filterChain.doFilter(request, response);
	}

	private UsernamePasswordAuthenticationToken getAuthentication(HttpServletRequest request) {
		String token = request.getHeader(TOKEN_HEADER);
		if (token != null) {
			String username = JWT.require(Algorithm.HMAC256(secret))
					.build()
					.verify(token)
					.getSubject();
			if (username != null) {
				User userDetails = ((LoginService) userDetailsService).loadUser(username);
				request.setAttribute("username", username);
				return new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
			}
		}
		return null;
	}
}
