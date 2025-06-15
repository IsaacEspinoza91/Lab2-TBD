package com.tbd.DeliveryMedicamentos.repositories;

import com.tbd.DeliveryMedicamentos.DTO.PtoInteresDTO; // Asegúrate de importar tu DTO
import com.tbd.DeliveryMedicamentos.entities.PtoInteresEntity; // Asegúrate de importar tu Entity
import org.springframework.beans.factory.annotation.Autowired;
import org.sql2o.Connection;
import org.sql2o.Sql2o;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class PtoInteresRepository {

    private final Sql2o sql2o;

    @Autowired
    public PtoInteresRepository(Sql2o sql2o) {
        this.sql2o = sql2o;
    }

    public List<PtoInteresEntity> findAll() {
        try (Connection conn = sql2o.open()) {
            // No recuperamos geom aquí, solo los datos básicos.
            // Si necesitas geom para algo, lo incluirías.
            return conn.createQuery("SELECT id, nombre, lugar FROM puntos_de_interes")
                    .executeAndFetch(PtoInteresEntity.class);
        }
    }

    public PtoInteresEntity findById(Integer id) {
        try (Connection conn = sql2o.open()) {
            // Si necesitas el campo geom para la entidad, lo incluyes aquí.
            // Para fines de persistencia o lógica interna, a veces es necesario.
            return conn.createQuery("SELECT id, nombre, lugar, ST_AsText(geom) AS geom FROM puntos_de_interes WHERE id = :id")
                    .addParameter("id", id)
                    .executeAndFetchFirst(PtoInteresEntity.class);
        }
    }

    public PtoInteresDTO findByIdConCoordenadas(Integer id) {
        try (Connection conn = sql2o.open()) {
            return conn.createQuery("SELECT nombre, lugar, ST_Y(geom) AS latitud, ST_X(geom) AS longitud FROM puntos_de_interes WHERE id = :id")
                    .addParameter("id", id)
                    .executeAndFetchFirst(PtoInteresDTO.class);
        }
    }

    public PtoInteresEntity save(PtoInteresEntity ptoInteres, Double latitud, Double longitud) {
        try (Connection conn = sql2o.open()) {
            // Asignamos el valor geom a la entidad antes de guardar
            ptoInteres.setGeom(latitud, longitud);
            int id = (Integer) conn.createQuery("INSERT INTO puntos_de_interes(nombre, lugar, geom) VALUES (:nombre, :lugar, ST_GeomFromText(:geom, 4326))", true)
                    .addParameter("nombre", ptoInteres.getNombre())
                    .addParameter("lugar", ptoInteres.getLugar())
                    // Usamos el campo 'geom' de la entidad que ya fue establecido
                    .addParameter("geom", ptoInteres.getGeom())
                    .executeUpdate()
                    .getKey();

            ptoInteres.setId(id);
            return ptoInteres;
        }
    }

    public void update(PtoInteresEntity ptoInteres, Double latitud, Double longitud) {
        try (Connection conn = sql2o.open()) {
            // También actualizamos la geometría si se proporcionan nuevas coordenadas
            if (latitud != null && longitud != null) {
                ptoInteres.setGeom(latitud, longitud);
                conn.createQuery("UPDATE puntos_de_interes SET nombre = :nombre, lugar = :lugar, geom = ST_GeomFromText(:geom, 4326) WHERE id = :id")
                        .addParameter("nombre", ptoInteres.getNombre())
                        .addParameter("lugar", ptoInteres.getLugar())
                        .addParameter("geom", ptoInteres.getGeom())
                        .addParameter("id", ptoInteres.getId())
                        .executeUpdate();
            } else {
                conn.createQuery("UPDATE puntos_de_interes SET nombre = :nombre, lugar = :lugar WHERE id = :id")
                        .addParameter("nombre", ptoInteres.getNombre())
                        .addParameter("lugar", ptoInteres.getLugar())
                        .addParameter("id", ptoInteres.getId())
                        .executeUpdate();
            }
        }
    }


    public void delete(Integer id) {
        try (Connection conn = sql2o.open()) {
            conn.createQuery("DELETE FROM puntos_de_interes WHERE id = :id")
                    .addParameter("id", id)
                    .executeUpdate();
        }
    }

    public long count() {
        try (Connection conn = sql2o.open()) {
            return conn.createQuery("SELECT COUNT(*) FROM puntos_de_interes")
                    .executeScalar(Long.class);
        }
    }

    // Aquí podrías agregar métodos específicos para puntos de interés si fuera necesario,
    // como buscar puntos cercanos a una ubicación, etc.
    // Por ejemplo:
    /*
    public List<PtoInteresDTO> findPuntosCercanos(Double latitud, Double longitud, Double radioMetros) {
        try (Connection conn = sql2o.open()) {
            String sql = "SELECT nombre, lugar, ST_Y(geom) AS latitud, ST_X(geom) AS longitud " +
                         "FROM puntos_de_interes " +
                         "WHERE ST_DWithin(geom, ST_SetSRID(ST_MakePoint(:longitud, :latitud), 4326)::geography, :radioMetros)";
            return conn.createQuery(sql)
                    .addParameter("latitud", latitud)
                    .addParameter("longitud", longitud)
                    .addParameter("radioMetros", radioMetros)
                    .executeAndFetch(PtoInteresDTO.class);
        }
    }
    */
}