package com.openinstall;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class OpenInstallApplication {
    public static void main(String[] args) {
        SpringApplication.run(OpenInstallApplication.class, args);
    }
}

