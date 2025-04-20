package pl.piomin.services.department.controller;



import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import pl.piomin.services.department.model.Department;

import java.sql.Timestamp;
import java.util.List;


@Validated
@RestController
@RequestMapping(value = "/api/v1/")
public class DocumentController {
	
	
	@GetMapping("/all")
	public String findAll() {
		return "ok";
	}

}
