package com.tbd.DeliveryMedicamentos.repositories;

import com.tbd.DeliveryMedicamentos.entities.PuntosEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.sql2o.Connection;
import org.sql2o.Sql2o;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class PuntosRepository {

    private final Sql2o sql2o;

    @Autowired
    public PuntosRepository(Sql2o sql2o) {
        this.sql2o = sql2o;
    }

    public PuntosEntity save(PuntosEntity punto, Double lat, Double lng) {
        try (Connection conn = sql2o.open()) {
            punto.setGeom(lat, lng);
            int id = conn.createQuery("INSERT INTO punto_de_entrega (nombre, Farmacia_ID, geom) VALUES (:nombre, :Farmacia_ID, ST_GeomFromText(:geom, 4326))", true)
                    .addParameter("nombre", punto.getNombre())
                    .addParameter("Farmacia_ID", punto.getidFarmacia())
                    .addParameter("geom", punto.getGeom())
                    .executeUpdate()
                    .getKey(Integer.class);
            punto.setId(id);
            return punto;
        }
    }

    /* Formato
    POST http://localhost:8080/api/puntos
    {
      "nombre": "Punto Providencia",
      "idFarmacia": 1,
      "latitud": -33.426209,
      "longitud": -70.617221
    }

     */

    public List<PuntosEntity> findAll() {
        try (Connection conn = sql2o.open()) {
            return conn.createQuery("SELECT id, nombre, Farmacia_ID, ST_AsText(geom) AS geom FROM puntos_entrega")
                    .executeAndFetch(PuntosEntity.class);
        }
    }

    public Optional<PuntosEntity> findById(int id) {
        try (Connection conn = sql2o.open()) {
            PuntosEntity punto = conn.createQuery("SELECT id, nombre, Farmacia_ID, ST_AsText(geom) AS geom FROM puntos_entrega WHERE id = :id")
                    .addParameter("id", id)
                    .executeAndFetchFirst(PuntosEntity.class);
            return Optional.ofNullable(punto);
        }
    }

    public boolean update(int id, PuntosEntity punto, Double lat, Double lng) {
        try (Connection conn = sql2o.open()) {
            punto.setGeom(lat, lng);
            int result = conn.createQuery("UPDATE puntos_entrega SET nombre = :nombre, Farmacia_ID = :Farmacia_ID, geom = ST_GeomFromText(:geom, 4326) WHERE id = :id")
                    .addParameter("id", id)
                    .addParameter("nombre", punto.getNombre())
                    .addParameter("lugar", punto.getidFarmacia())
                    .addParameter("geom", punto.getGeom())
                    .executeUpdate()
                    .getResult();
            return result > 0;
        }
    }

    public boolean delete(int id) {
        try (Connection conn = sql2o.open()) {
            int result = conn.createQuery("DELETE FROM puntos_entrega WHERE id = :id")
                    .addParameter("id", id)
                    .executeUpdate()
                    .getResult();
            return result > 0;
        }
    }
}
