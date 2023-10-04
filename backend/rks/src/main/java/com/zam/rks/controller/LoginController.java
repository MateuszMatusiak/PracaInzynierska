package com.zam.rks.controller;

import com.zam.rks.Service.LoginService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.LoginCredentials;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class LoginController {

	private final LoginService loginService;

	public LoginController(LoginService loginService) {
		this.loginService = loginService;
	}

	@PostMapping("/login")
	public void login(@RequestBody LoginCredentials credentials) {
	}

	@PostMapping("/register")
	public ResponseEntity<?> register(@RequestBody LoginCredentials user) {
		return U.handleReturn(() -> loginService.saveNewUser(user));
	}

	@GetMapping("/confirm")
	public String confirmToken(@RequestParam("token") String token) {
		return loginService.confirmToken(token);
	}
}
