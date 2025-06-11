<template>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <router-link class="navbar-brand" to="/home2">Delivery Medicamentos</router-link>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item" v-if="!authStore.isAuthenticated">
                        <router-link class="nav-link" to="/login2">Iniciar Sesión</router-link>
                    </li>
                    <li class="nav-item" v-if="!authStore.isAuthenticated">
                        <router-link class="nav-link" to="/register2">Registrarse</router-link>
                    </li>
                    <li class="nav-item dropdown" v-if="authStore.isAuthenticated">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button"
                            data-bs-toggle="dropdown">
                            <img src="../../assets/user-icon.png" alt="Usuario" class="rounded-circle" width="30"
                                height="30">
                            {{ authStore.user?.nombreUsuario }}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><button class="dropdown-item" @click="authStore.logout">Cerrar Sesión</button></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>


        <!-- Modal de confirmación -->
        <div v-if="showLogoutModal" class="modal-backdrop fade show"></div>
        <div class="modal fade" :class="{ 'show d-block': showLogoutModal }">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Confirmar cierre de sesión</h5>
                        <button type="button" class="btn-close" @click="showLogoutModal = false"></button>
                    </div>
                    <div class="modal-body">
                        <p>¿Estás seguro que deseas cerrar tu sesión?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" @click="showLogoutModal = false">
                            Cancelar
                        </button>
                        <button type="button" class="btn btn-danger" @click="handleLogout">
                            Cerrar Sesión
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </nav>
</template>

<script>
import { useAuthStore } from '../../stores/auth2'
import { ref } from 'vue'
import { useRouter } from 'vue-router'

export default {
    setup() {
        const authStore = useAuthStore()
        const router = useRouter()
        const showLogoutModal = ref(false)

        const handleLogout = () => {
            authStore.logout()
            showLogoutModal.value = false
            router.push('/home2')
        }

        return { authStore, showLogoutModal, handleLogout }
    }
}
</script>

<style scoped>
.navbar {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>