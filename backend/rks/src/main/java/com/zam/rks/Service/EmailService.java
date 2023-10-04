package com.zam.rks.Service;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

@Service
@AllArgsConstructor
public class EmailService {
	private JavaMailSender mailSender;
	private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

	public boolean sendVerificationMessage(String to, String verificationLink) {
		String subject = "Weryfikacja konta";
		String message = "<!DOCTYPE html> <html><head>" +
				"<title>Link weryfikacyjny do aplikacji Legancka</title>   " +
				"</head><body>" +
				"<p>Witaj,</p>" +
				"<p>Dziękujemy za rejestrację w aplikacji. Aby potwierdzić swoje konto, kliknij w poniższy link:</p>" +
				"<p><a href=\"" + verificationLink + "\">" + verificationLink + "</a></p>     " +
				"<p>Pozdrawiamy,</p>" +
				"<p>Zespół aplikacji Legancka</p>" +
				"</body> </html>";
		return sendEmail(to, subject, message);
	}

	private boolean sendEmail(String to, String subject, String body) {
		try {
			MimeMessage mimeMessage = mailSender.createMimeMessage();
			MimeMessageHelper helper =
					new MimeMessageHelper(mimeMessage, "utf-8");
			helper.setText(body, true);
			helper.setTo(to);
			helper.setSubject(subject);
			mailSender.send(mimeMessage);
			logger.info("Email sent to: " + to + " with subject: " + subject);
			return true;
		} catch (MessagingException e) {
			logger.warn("Error sending email to: " + to + " with subject: " + subject + " error: " + e.getMessage());
			return false;
		}
	}


}
