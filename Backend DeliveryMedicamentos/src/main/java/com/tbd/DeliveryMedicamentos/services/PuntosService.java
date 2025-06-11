package com.tbd.DeliveryMedicamentos.services;

import com.tbd.DeliveryMedicamentos.entities.PuntosEntity;
import com.tbd.DeliveryMedicamentos.repositories.PuntosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PuntosService {

    private final PuntosRepository puntosRepository;

    @Autowired
    public PuntosService(PuntosRepository puntosRepository) {
        this.puntosRepository = puntosRepository;
    }

    public PuntosEntity createPunto(PuntosEntity punto, Double lat, Double lng) {
        return puntosRepository.save(punto, lat, lng);
    }

    public List<PuntosEntity> getAllPuntos() {
        return puntosRepository.findAll();
    }

    public Optional<PuntosEntity> getPuntoById(int id) {
        return puntosRepository.findById(id);
    }

    public boolean updatePunto(int id, PuntosEntity punto, Double lat, Double lng) {
        return puntosRepository.update(id, punto, lat, lng);
    }

    public boolean deletePunto(int id) {
        return puntosRepository.delete(id);
    }
}
