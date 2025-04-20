package pl.piomin.services.config;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.config.server.EnableConfigServer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
@SpringBootApplication
@EnableConfigServer
public class ConfigApplication {
    private static final Logger logger = LogManager.getLogger(ConfigApplication.class);
	public static void main(String[] args) {
		 logger.info("Đang khởi động ứng dụng...");
		new SpringApplicationBuilder(ConfigApplication.class).run(args);
		  logger.info("Đã khởi động ứng dụng...");
	}

}
