package com.zam.rks.Service;

import com.zam.rks.Repository.ConfirmationTokenRepository;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.model.ConfirmationToken;
import com.zam.rks.model.TokenResult;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@AllArgsConstructor
public class ConfirmationTokenService {

	private final ConfirmationTokenRepository confirmationTokenRepository;
	private final UserRepository userRepository;
	private static final Logger logger = LoggerFactory.getLogger(ConfirmationTokenService.class);

	public void saveConfirmationToken(ConfirmationToken token) {
		confirmationTokenRepository.save(token);
	}

	@Transactional
	public TokenResult confirmToken(String token) {
		Optional<ConfirmationToken> test = confirmationTokenRepository.findByToken(token);
		if (test.isEmpty()) {
			return TokenResult.TOKEN_NOT_FOUND;
		}
		ConfirmationToken confirmationToken = test.get();
		
		if (confirmationToken.getConfirmedAt() != null) {
			logger.warn("Email already confirmed: " + confirmationToken.getUser().getEmail());
			return TokenResult.EMAIL_ALREADY_CONFIRMED;
		}

		LocalDateTime expiredAt = confirmationToken.getExpiresAt();

		if (expiredAt.isBefore(LocalDateTime.now())) {
			logger.warn("Token expired: " + confirmationToken.getUser().getEmail());
			return TokenResult.TOKEN_EXPIRED;
		}

		confirmationTokenRepository.updateConfirmedAt(token, LocalDateTime.now());
		userRepository.enableAppUser(confirmationToken.getUser().getEmail());
		logger.info("Email confirmed: " + confirmationToken.getUser().getEmail());
		return TokenResult.EMAIL_CONFIRMED;

	}
}
