<template>
  <div class="dashboard">
    <h1>Resumen del Sistema</h1>
    <div class="stats-grid">
      <router-link to="/admin/usuarios" class="stat-card clickable-card">
        <h3>Usuarios</h3>
        <div v-if="loading" class="loading-indicator">
          <div class="loader"></div>
          <span>Cargando...</span>
        </div>
        <p v-else>{{ usuariosCount }}</p>
      </router-link>

      <router-link to="/admin/farmacias" class="stat-card clickable-card">
        <h3>Farmacias</h3>
        <div v-if="loading" class="loading-indicator">
          <div class="loader"></div>
          <span>Cargando...</span>
        </div>
        <p v-else>{{ farmaciasCount }}</p>
      </router-link>

      <router-link to="/admin/pedidos" class="stat-card clickable-card">
        <h3>Pedidos del Mes</h3>
        <div v-if="loading" class="loading-indicator">
          <div class="loader"></div>
          <span>Cargando...</span>
        </div>
        <p v-else>{{ pedidosMesCount }}</p>
      </router-link>

      <router-link to="/admin/productos" class="stat-card clickable-card">
        <h3>Productos</h3>
        <div v-if="loading" class="loading-indicator">
          <div class="loader"></div>
          <span>Cargando...</span>
        </div>
        <p v-else>{{ productosCount }}</p>
      </router-link>
    </div>

    <!-- Sección de consultas -->
    <div class="consultas-section">
      <h2>Consultas del Sistema</h2>
      <div class="consulta-selector">
        <select v-model="consultaSeleccionada" @change="ejecutarConsulta" class="consulta-dropdown">
          <option value="" disabled selected>Seleccione una consulta...</option>
          <option value="1">Consulta N°1: Encontrar los 5 puntos de entrega más cercanos a una farmacia o empresa asociada.</option>
          <option value="2">Consulta N°2: Determinar si un cliente se encuentra dentro de una zona de cobertura.</option>
          <option value="3">Consulta N°3: Calcular la distancia total recorrida por un repartidor en el último mes.</option>
          <option value="4">Consulta N°4: Identificar el punto de entrega más lejano desde cada empresa asociada.</option>
          <option value="5">Consulta N°5: Listar todos los pedidos cuya ruta estimada cruce más de 2 zonas de reparto.</option>
          <option value="6">Consulta N°6: Determinar los clientes que están a más de 5km de cualquier empresa o farmacia.</option>
        </select>

        <div v-if="consultaCargando" class="loading-indicator">
          <div class="loader"></div>
          <span>Ejecutando consulta...</span>
        </div>

        <div v-if="resultadoConsulta" class="resultado-consulta">
          <h3>Resultado:</h3>
          <!-- Display para la consulta 3: Lista de objetos -->
          <div v-if="consultaSeleccionada === '3'">
            <table class="resultado-table">
              <thead>
              <tr>
                <th>Repartidor</th>
                <th>Mes</th>
                <th>Distancia (Metros)</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="(item, index) in resultadoConsulta" :key="index">
                <td>{{ item.repartidor_Nombre }} {{ item.repartidor_Apellido }}</td>
                <td>{{ item.mes_Entrega }}</td>
                <td>{{ parseFloat(item.distancia_Total_Metros).toFixed(2) }}</td>
              </tr>
              </tbody>
            </table>
          </div>
          <!-- Display para la consulta 6: Lista de clientes lejanos -->
          <div v-else-if="consultaSeleccionada === '6'">
            <table class="resultado-table">
              <thead>
              <tr>
                <th>ID Cliente</th>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Distancia Mínima (km)</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="(cliente, index) in resultadoConsulta" :key="index">
                <td>{{ cliente.cliente_id }}</td>
                <td>{{ cliente.nombre }}</td>
                <td>{{ cliente.apellido }}</td>
                <td>{{ parseFloat(cliente.distancia_minima_km).toFixed(2) }}</td>
              </tr>
              </tbody>
            </table>
          </div>
          <pre v-else>{{ JSON.stringify(resultadoConsulta, null, 2) }}</pre>
        </div>

        <div v-if="errorConsulta" class="error-consulta">
          <p class="error-message">{{ errorConsulta }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'

const farmaciasCount = ref(0)
const usuariosCount = ref(0)
const productosCount = ref(0)
const pedidosMesCount = ref(0)
const loading = ref(true)

// Variables para las consultas
const consultaSeleccionada = ref('')
const consultaCargando = ref(false)
const resultadoConsulta = ref(null)
const errorConsulta = ref(null)

const fetchData = async () => {
  try {
    loading.value = true
    const [farmaciasRes, usuariosRes, productosRes, pedidosRes] = await Promise.all([
      api.get('/farmacias/contar'),
      api.get('/usuarios/contar'),
      api.get('/productos/contar'),
      api.get('/pedidos/contar-mes')
    ])

    farmaciasCount.value = farmaciasRes.data.count
    usuariosCount.value = usuariosRes.data.count
    productosCount.value = productosRes.data.count
    pedidosMesCount.value = pedidosRes.data.count

  } catch (error) {
    console.error('Error al cargar datos:', error)
  } finally {
    loading.value = false
  }
}

const ejecutarConsulta = async () => {
  if (!consultaSeleccionada.value) return

  try {
    consultaCargando.value = true
    resultadoConsulta.value = null
    errorConsulta.value = null

    let response;

    switch(consultaSeleccionada.value) {
      case '3':
        response = await api.get('/repartidores/distancia-mensual');
        break;
      case '6':
        response = await api.get('/clientes/lejanos-5km');
        break;
      default:
        response = await api.get(`/consultas/consulta-${consultaSeleccionada.value}`);
    }

    resultadoConsulta.value = response.data;

  } catch (error) {
    console.error('Error al ejecutar consulta:', error);
    errorConsulta.value = error.response?.data?.message || 'Error al ejecutar la consulta';
  } finally {
    consultaCargando.value = false;
  }
};

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: transform 0.3s;
}

.clickable-card {
  cursor: pointer;
  text-decoration: none;
  color: inherit;
}

.clickable-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  background-color: #f8f9fa;
}

.stat-card h3 {
  color: #555;
  margin-bottom: 0.5rem;
  font-size: 1.2rem;
}

.stat-card p {
  font-size: 2.5rem;
  font-weight: bold;
  color: #1a237e;
  margin: 1rem 0;
}

/* Estilos para la sección de consultas */
.consultas-section {
  margin-top: 3rem;
  padding: 1.5rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.consultas-section h2 {
  color: #1a237e;
  margin-bottom: 1.5rem;
}

.consulta-dropdown {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  margin-bottom: 1rem;
}

.resultado-consulta {
  margin-top: 1.5rem;
  padding: 1rem;
  background-color: #f5f5f5;
  border-radius: 4px;
  max-height: 300px;
  overflow-y: auto;
}

.resultado-consulta h3 {
  color: #1a237e;
  margin-bottom: 0.5rem;
}

.resultado-consulta pre {
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: monospace;
}

/* Estilos específicos para la tabla de resultados de consulta */
.resultado-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.resultado-table th,
.resultado-table td {
  padding: 8px 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.resultado-table thead th {
  background-color: #e9e9e9;
  font-weight: bold;
}

.resultado-table tbody tr:hover {
  background-color: #f0f0f0;
}

.error-consulta {
  margin-top: 1rem;
  padding: 1rem;
  background-color: #ffebee;
  border-radius: 4px;
  color: #c62828;
}

.error-message {
  margin: 0;
}

.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin: 1rem 0;
}

.loader {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #1a237e;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>