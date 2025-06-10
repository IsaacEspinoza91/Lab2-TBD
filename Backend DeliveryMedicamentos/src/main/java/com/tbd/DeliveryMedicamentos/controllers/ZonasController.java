package com.tbd.DeliveryMedicamentos.controllers;

import com.tbd.DeliveryMedicamentos.entities.ZonasEntity;
import com.tbd.DeliveryMedicamentos.services.ZonasService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/zonas")
public class ZonasController {

    private final ZonasService zonasService;

    @Autowired
    public ZonasController(ZonasService zonasService) {
        this.zonasService = zonasService;
    }

    @GetMapping
    public List<ZonasEntity> getAll() {
        return zonasService.findAll();
    }

    @GetMapping("/{id}")
    public Optional<ZonasEntity> getById(@PathVariable int id) {
        return zonasService.findById(id);
    }

    @PostMapping
    public ZonasEntity create(@RequestBody ZonasEntity zona) {
        return zonasService.save(zona);
    }

    @PutMapping("/{id}")
    public boolean update(@PathVariable int id, @RequestBody ZonasEntity zona) {
        return zonasService.update(id, zona);
    }

    @DeleteMapping("/{id}")
    public boolean delete(@PathVariable int id) {
        return zonasService.delete(id);
    }
}
