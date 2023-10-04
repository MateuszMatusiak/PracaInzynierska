package com.zam.rks.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.ConfirmationToken;
import com.zam.rks.model.LoginCredentials;
import com.zam.rks.model.TokenResult;
import com.zam.rks.model.User;
import com.zam.rks.security.PasswordEncoder;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Scope
@AllArgsConstructor
public class LoginService implements UserDetailsService {
	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final UtilService utilService;
	private final ConfirmationTokenService confirmationTokenService;
	private final EmailService emailService;
	private final ObjectMapper objectMapper;
	private static final Logger logger = LoggerFactory.getLogger(LoginService.class);

	@Transactional
	public String saveNewUser(LoginCredentials user) throws JsonProcessingException {
		Optional<User> test = userRepository.findByEmail(user.email());
		if (test.isPresent()) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "User already exists");
		}
		User userToSave = new User(user.email(), passwordEncoder.encode(user.password()));
		User saved = userRepository.save(userToSave);
		String token = UUID.randomUUID().toString();
		ConfirmationToken confirmationToken = new ConfirmationToken(
				token,
				LocalDateTime.now(),
				LocalDateTime.now().plusMinutes(15),
				userToSave
		);
		confirmationTokenService.saveConfirmationToken(confirmationToken);
		RestTemplate restTemplate = new RestTemplate();
		String ipAddress = restTemplate.getForObject("https://api.ipify.org", String.class);

		String link = "http://" + ipAddress + ":4567/confirm?token=" + token;

		emailService.sendVerificationMessage(userToSave.getEmail(), link);

		logger.info("User registered: " + saved.getId());
		return String.valueOf(saved.getId());
	}

	public String confirmToken(String token) {
		String head = """
				<!DOCTYPE html>
				<html>
					<head>
					<title>Potwierdzenie adresu e-mail</title>
						<style>
					        body {
					            font-family: Arial, sans-serif;
					            margin: 0;
					            padding: 0;
					        }
					        h1 {
					            font-size: 2em;
					            text-align: center;
					            margin-top: 2em;
					        }
					        p {
					            font-size: 1.2em;
					            margin: 1em;
					            line-height: 1.5;
					            text-align: center;
					        }
					    </style>
					</head>
				<body>
				""";

		TokenResult tokenResult = confirmationTokenService.confirmToken(token);
		if (tokenResult == TokenResult.EMAIL_CONFIRMED) {
			return head +
					"<h1>Adres e-mail potwierdzony</h1>\n" +
					"<p>Dziękujemy za potwierdzenie adresu e-mail. Twój adres e-mail został pomyślnie zweryfikowany.</p>\n" +
					"</body>\n" +
					"</html>";
		} else if (tokenResult == TokenResult.TOKEN_NOT_FOUND) {
			return head +
					"<h1>Token nie znaleziony</h1>\n" +
					"<p>Przepraszamy, podany token nie został odnaleziony w naszej bazie danych.</p>\n" +
					"</body>\n" +
					"</html>";
		} else if (tokenResult == TokenResult.TOKEN_EXPIRED) {
			return head +
					"<h1>Token wygasł</h1>\n" +
					"<p>Przepraszamy, podany token wygasł. Prosimy o kontakt z administracją w celu ponownego wygenerowania tokenu.</p>\n" +
					"</body>\n" +
					"</html>";
		} else if (tokenResult == TokenResult.EMAIL_ALREADY_CONFIRMED) {
			return head +
					"<h1>Adres e-mail już potwierdzony</h1>\n" +
					"<p>Podany adres e-mail został już wcześniej potwierdzony. Dziękujemy!</p>\n" +
					"</body>\n" +
					"</html>";
		} else {
			return "";
		}
	}

	@Transactional
	@Override
	public UserDetails loadUserByUsername(String usernameAndDevice) throws UsernameNotFoundException {
		String[] split = usernameAndDevice.split(String.valueOf(Character.LINE_SEPARATOR));
		String username = split[0];
		String deviceToken = split[1];
		User user = userRepository.findByEmail(username).orElseThrow(() -> new UsernameNotFoundException("User not found"));
		utilService.setGroupsAndRole(user);
		if (!deviceToken.isEmpty()) {
			List<String> deviceTokens = user.getDeviceTokens();
			if (!deviceTokens.contains(deviceToken)) {
				deviceTokens.add(deviceToken);
				userRepository.save(user);
			}
		}
		return user;
	}

	public User loadUser(String username) {
		User user = userRepository.findByEmail(username).orElseThrow(() -> new UsernameNotFoundException("User not found"));
		utilService.setGroupsAndRole(user);
		return user;
	}
}
