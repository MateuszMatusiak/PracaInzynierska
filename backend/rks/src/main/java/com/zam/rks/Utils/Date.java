package com.zam.rks.Utils;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeParseException;

public class Date {
	private int year = 2000;
	private int month = 1;
	private int day = 1;
	private int hour = 0;
	private int minutes = 0;
	private String stringDate;
	private Timestamp timestamp;
	private LocalDateTime localDateTime;

	public Date(String stringDate) {
		if (stringDate == null) {
			this.timestamp = null;
			this.stringDate = "";
			this.localDateTime = null;
		} else {
			this.init(stringDate);
			this.localDateTime = LocalDateTime.of(year, month, day, hour, minutes);
			this.timestamp = new Timestamp(ZonedDateTime.of(this.localDateTime, ZoneId.systemDefault()).toInstant().toEpochMilli());
		}
	}

	public Date(Timestamp timestamp) {
		if (timestamp == null) {
			this.timestamp = null;
			this.stringDate = "";
			this.localDateTime = null;
		} else {
			this.init(timestamp.toString().substring(0, 16));
			this.localDateTime = LocalDateTime.of(year, month, day, hour, minutes);
		}
	}

	private void init(String stringDate) {
		try {
			this.stringDate = stringDate;
			this.year = Integer.parseInt(this.stringDate.substring(0, 4));
			this.month = Integer.parseInt(this.stringDate.substring(5, 7));
			this.day = Integer.parseInt(this.stringDate.substring(8, 10));
			this.hour = Integer.parseInt(this.stringDate.substring(11, 13));
			this.minutes = Integer.parseInt(this.stringDate.substring(14, 16));
		} catch (Exception e) {
			throw new DateTimeParseException("Wrong date pattern", this.stringDate, 0);
		}
	}

	public Timestamp getTimestamp() {
		return timestamp;
	}

	public LocalDateTime getLocalDateTime() {
		return localDateTime;
	}

	public String getStringDate() {
		return stringDate;
	}

	@Override
	public String toString() {
		return this.stringDate;
	}
}
